//! Chapter 36, exercise 2: a shared counter, three ways.
//! Run with:  zig test ex2_counter.zig
//! Goal: fill in the atomic and mutex versions of `bump` so both tests
//! count exactly 4 * 100_000. The plain version is left as a demonstration
//! of a data race and is not tested (its result is not defined).
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

const per_thread = 100_000;
const n_threads = 4;

var atomic_count: std.atomic.Value(u64) = .init(0);

fn bumpAtomic() void {
    // TODO: per_thread times, fetchAdd 1
}

var mutex_count: u64 = 0;
var mutex: std.Io.Mutex = .init;

fn bumpMutex(io: std.Io) void {
    // TODO: per_thread times, lock, increment, unlock
    _ = io;
}

test "atomic counter is exact" {
    var threads: [n_threads]std.Thread = undefined;
    for (&threads) |*t| t.* = try std.Thread.spawn(.{}, bumpAtomic, .{});
    for (threads) |t| t.join();
    try std.testing.expectEqual(@as(u64, n_threads * per_thread), atomic_count.load(.seq_cst));
}

test "mutex counter is exact" {
    const io = std.testing.io;
    var threads: [n_threads]std.Thread = undefined;
    for (&threads) |*t| t.* = try std.Thread.spawn(.{}, bumpMutex, .{io});
    for (threads) |t| t.join();
    try std.testing.expectEqual(@as(u64, n_threads * per_thread), mutex_count);
}
