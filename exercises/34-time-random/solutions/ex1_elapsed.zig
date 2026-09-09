//! Chapter 34, exercise 1: measuring elapsed time.
//! Run with:  zig run ex1_elapsed.zig
//! Goal: time three sizes of a busy loop with the monotonic clock and print
//! each duration in milliseconds. Your numbers will differ; the shape
//! (each line roughly ten times the last) should not.
//!
//! Example output:
//!   n=1000000     sum=499999500000        took 1 ms
//!   n=10000000    sum=49999995000000      took 12 ms
//!   n=100000000   sum=4999999950000000    took 121 ms

const std = @import("std");

fn busyLoop(n: u64) u64 {
    var sum: u64 = 0;
    var i: u64 = 0;
    while (i < n) : (i += 1) sum +%= i;
    return sum;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [256]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const out = &w.interface;

    const sizes = [_]u64{ 1_000_000, 10_000_000, 100_000_000 };
    for (sizes) |n| {
        const t0 = std.Io.Clock.now(.awake, io);
        const sum = busyLoop(n);
        const t1 = std.Io.Clock.now(.awake, io);
        const took = t0.durationTo(t1);
        try out.print("n={d:<12} sum={d:<20} took {d} ms\n", .{ n, sum, took.toMilliseconds() });
    }
    try out.flush();
}
