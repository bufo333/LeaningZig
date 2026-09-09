//! Chapter 36, exercise 3: a parallel sum over a slice.
//! Run with:  zig test ex3_parallel_sum.zig
//! Goal: implement `parallelSum` so it splits `data` into `n_threads`
//! chunks, sums each chunk on its own thread, and returns the total.
//! Handle a slice shorter than n_threads and a remainder chunk.
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

fn sumChunk(chunk: []const u32, out: *u64) void {
    var s: u64 = 0;
    for (chunk) |v| s += v;
    out.* = s;
}

pub fn parallelSum(data: []const u32, comptime n_threads: usize) !u64 {
    // TODO: split data into n_threads chunks (last may be short; there may be
    // fewer items than threads), spawn sumChunk per chunk with its own slot,
    // join, and add the slots.
    _ = data;
    _ = n_threads;
    return 0;
}

test "matches a serial sum" {
    var data: [1001]u32 = undefined;
    for (&data, 0..) |*d, i| d.* = @intCast(i);
    var serial: u64 = 0;
    for (data) |v| serial += v;
    try std.testing.expectEqual(serial, try parallelSum(&data, 4));
    try std.testing.expectEqual(serial, try parallelSum(&data, 7));
}

test "short slices and empty slices" {
    const two = [_]u32{ 5, 6 };
    try std.testing.expectEqual(@as(u64, 11), try parallelSum(&two, 8));
    const none = [_]u32{};
    try std.testing.expectEqual(@as(u64, 0), try parallelSum(&none, 4));
}
