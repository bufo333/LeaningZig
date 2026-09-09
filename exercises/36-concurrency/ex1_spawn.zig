//! Chapter 36, exercise 1: spawn and join.
//! Run with:  zig run ex1_spawn.zig
//! Goal: start four worker threads, each computing the sum of its own
//! range into its own slot, then join them and add the slots. The
//! per-thread lines may appear in any order. Expected output:
//!   worker 0: 0..250000
//!   worker 1: 250000..500000
//!   worker 2: 500000..750000
//!   worker 3: 750000..1000000
//!   total = 499999500000
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

fn worker(id: usize, lo: u64, hi: u64, out: *u64) void {
    std.debug.print("worker {d}: {d}..{d}\n", .{ id, lo, hi });
    // TODO: sum lo..hi into out.*
    _ = out;
}

pub fn main() !void {
    const n_threads = 4;
    const total_n: u64 = 1_000_000;
    var slots: [n_threads]u64 = undefined;
    // TODO: spawn one thread per slot with std.Thread.spawn, join them all,
    // add up the slots and print the total.
    _ = &slots;
    _ = total_n;
}
