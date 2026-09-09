//! Chapter 26, exercise 2: a fixed-capacity ring buffer queue.
//! Run with:  zig test ex2_ring.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// A queue of at most N items of type T, with no allocator at all.
fn Ring(comptime T: type, comptime N: usize) type {
    return struct {
        const Self = @This();

        buf: [N]T = undefined,
        head: usize = 0, // index of the oldest item
        count: usize = 0,

        pub fn push(self: *Self, v: T) error{Full}!void {
            if (self.count == N) return error.Full;
            self.buf[(self.head + self.count) % N] = v;
            self.count += 1;
        }

        pub fn pop(self: *Self) ?T {
            _ = self;
            // TODO
        }

        pub fn len(self: Self) usize {
            _ = self;
            // TODO
        }

        pub fn capacity(_: Self) usize {
            // TODO
        }
    };
}

test "fifo order" {
    var q: Ring(u8, 3) = .{};
    try q.push(1);
    try q.push(2);
    try q.push(3);
    try std.testing.expectError(error.Full, q.push(4));
    try std.testing.expectEqual(@as(?u8, 1), q.pop());
    try q.push(4); // wraps around
    try std.testing.expectEqual(@as(?u8, 2), q.pop());
    try std.testing.expectEqual(@as(?u8, 3), q.pop());
    try std.testing.expectEqual(@as(?u8, 4), q.pop());
    try std.testing.expectEqual(@as(?u8, null), q.pop());
}

test "size is decided at compile time" {
    var q: Ring([]const u8, 2) = .{};
    try std.testing.expectEqual(@as(usize, 2), q.capacity());
    try q.push("a");
    try std.testing.expectEqual(@as(usize, 1), q.len());
    try std.testing.expect(@sizeOf(Ring(u8, 4)) < @sizeOf(Ring(u8, 64)));
}
