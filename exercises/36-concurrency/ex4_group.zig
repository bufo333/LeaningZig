//! Chapter 36, exercise 4: the same work with std.Io.Group.
//! Run with:  zig run ex4_group.zig
//! Goal: rewrite the parallel sum with an Io.Group instead of raw
//! threads, and time both. Expected output (timings vary):
//!   threads: 4999999950000000 in 30 ms
//!   group:   4999999950000000 in 30 ms
//!   cpus: 14
//! STARTER: this file does not compile until you fill in the TODOs.

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
    _ = &parts;

    // TODO: time n_tasks raw threads summing the chunks, then time an
    // std.Io.Group doing the same, then print std.Thread.getCpuCount().
    _ = io;
}
