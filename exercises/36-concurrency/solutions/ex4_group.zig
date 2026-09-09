//! Chapter 36, exercise 4: the same work with std.Io.Group.
//! Run with:  zig run ex4_group.zig
//! Goal: rewrite the parallel sum with an Io.Group instead of raw
//! threads, and time both. Expected output (timings vary):
//!   threads: 4999999950000000 in 30 ms
//!   group:   4999999950000000 in 30 ms
//!   cpus: 14

const std = @import("std");

fn sumChunk(chunk: []const u64, out: *u64) void {
    var s: u64 = 0;
    for (chunk) |v| s += v;
    out.* = s;
}

const n = 100_000_000;
const n_tasks = 8;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const data = try init.gpa.alloc(u64, n);
    defer init.gpa.free(data);
    for (data, 0..) |*d, i| d.* = i;
    var parts: [n_tasks]u64 = undefined;
    const chunk = n / n_tasks;

    var t0 = std.Io.Clock.now(.awake, io);
    var threads: [n_tasks]std.Thread = undefined;
    for (&threads, 0..) |*t, i| {
        t.* = try std.Thread.spawn(.{}, sumChunk, .{ data[i * chunk .. (i + 1) * chunk], &parts[i] });
    }
    for (threads) |t| t.join();
    var total: u64 = 0;
    for (parts) |p| total += p;
    var t1 = std.Io.Clock.now(.awake, io);
    std.debug.print("threads: {d} in {d} ms\n", .{ total, t0.durationTo(t1).toMilliseconds() });

    t0 = std.Io.Clock.now(.awake, io);
    var group: std.Io.Group = .init;
    for (0..n_tasks) |i| {
        group.async(io, sumChunk, .{ data[i * chunk .. (i + 1) * chunk], &parts[i] });
    }
    try group.await(io);
    total = 0;
    for (parts) |p| total += p;
    t1 = std.Io.Clock.now(.awake, io);
    std.debug.print("group:   {d} in {d} ms\n", .{ total, t0.durationTo(t1).toMilliseconds() });
    std.debug.print("cpus: {d}\n", .{try std.Thread.getCpuCount()});
}
