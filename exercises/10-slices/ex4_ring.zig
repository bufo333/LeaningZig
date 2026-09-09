//! Chapter 10, exercise 4: a fixed-size log with a slice view (challenge).
//! Run with:  zig test ex4_ring.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// Keeps the last 4 values pushed. Older values are overwritten.
const Log = struct {
    buf: [4]u32 = undefined,
    len: usize = 0, // how many slots are valid (0..4)
    next: usize = 0, // where the next push goes

    fn push(self: *Log, v: u32) void {
        _ = self;
        _ = v;
        // TODO: store at next, advance next with wrap-around, grow len up to 4
    }

    /// Copy the valid values, oldest first, into `out` and return the filled part.
    fn ordered(self: Log, out: []u32) []u32 {
        _ = self;
        _ = out;
        // TODO: the oldest value is at index 0 until the buffer is full,
        // then it is at `next`.
    }

    /// The valid part of the raw buffer (no reordering).
    fn raw(self: *const Log) []const u32 {
        _ = self;
        // TODO
    }
};

test "fills up then wraps" {
    var log = Log{};
    var out: [4]u32 = undefined;
    try std.testing.expectEqual(@as(usize, 0), log.ordered(&out).len);
    log.push(1);
    log.push(2);
    try std.testing.expectEqualSlices(u32, &[_]u32{ 1, 2 }, log.ordered(&out));
    log.push(3);
    log.push(4);
    log.push(5); // overwrites 1
    try std.testing.expectEqualSlices(u32, &[_]u32{ 2, 3, 4, 5 }, log.ordered(&out));
    try std.testing.expectEqualSlices(u32, &[_]u32{ 5, 2, 3, 4 }, log.raw());
}
