//! Chapter 19, exercise 1: allocate, fill, hand over, free.
//! Run with:  zig test ex1_alloc.zig
//! Goal: make every test pass without changing the tests. The testing
//! allocator fails the test if you leak.
const std = @import("std");

/// The first `n` square numbers. Caller owns the result and frees it with `a`.
fn squares(a: std.mem.Allocator, n: usize) ![]u32 {
    const out = try a.alloc(u32, n);
    for (out, 0..) |*x, i| x.* = @intCast(i * i);
    return out;
}

/// A fresh, upper-cased copy of `s`. Caller owns it.
fn shout(a: std.mem.Allocator, s: []const u8) ![]u8 {
    const out = try a.dupe(u8, s);
    for (out) |*c| c.* = std.ascii.toUpper(c.*);
    return out;
}

test "squares" {
    const a = std.testing.allocator;
    const sq = try squares(a, 5);
    defer a.free(sq);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 4, 9, 16 }, sq);
}

test "shout" {
    const a = std.testing.allocator;
    const s = try shout(a, "contract signed");
    defer a.free(s);
    try std.testing.expectEqualStrings("CONTRACT SIGNED", s);
}
