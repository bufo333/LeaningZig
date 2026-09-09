//! Chapter 26, exercise 1: a generic pair.
//! Run with:  zig test ex1_pair.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

fn Pair(comptime A: type, comptime B: type) type {
    return struct {
        first: A,
        second: B,

        const Self = @This();

        pub fn swap(self: Self) Pair(B, A) {
            return .{ .first = self.second, .second = self.first };
        }

        /// Apply `f` to the first element, producing a pair with a new first type.
        pub fn mapFirst(self: Self, comptime f: anytype) Pair(@TypeOf(f(self.first)), B) {
            return .{ .first = f(self.first), .second = self.second };
        }
    };
}

/// Build a pair with both types inferred from the arguments.
fn pair(a: anytype, b: anytype) Pair(@TypeOf(a), @TypeOf(b)) {
    return .{ .first = a, .second = b };
}

fn double(x: u32) u64 {
    return @as(u64, x) * 2;
}

test "swap" {
    const p = pair(@as(u32, 7), @as([]const u8, "seven"));
    const q = p.swap();
    try std.testing.expectEqualStrings("seven", q.first);
    try std.testing.expectEqual(@as(u32, 7), q.second);
    try std.testing.expect(@TypeOf(q) == Pair([]const u8, u32));
}

test "mapFirst changes the type" {
    const p = pair(@as(u32, 21), true);
    const m = p.mapFirst(double);
    try std.testing.expectEqual(@as(u64, 42), m.first);
    try std.testing.expect(m.second);
    try std.testing.expect(@TypeOf(m) == Pair(u64, bool));
}

test "same arguments, same type" {
    try std.testing.expect(Pair(u8, u8) == Pair(u8, u8));
    try std.testing.expect(Pair(u8, u8) != Pair(u8, u16));
}
