//! Chapter 19, exercise 1: allocate, fill, hand over, free.
//! Run with:  zig test ex1_alloc.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.) The testing
//! allocator fails the test if you leak.
const std = @import("std");

/// The first `n` square numbers. Caller owns the result and frees it with `a`.
fn squares(a: std.mem.Allocator, n: usize) ![]u32 {
    // TODO: implement
    @panic("TODO");
}

/// A fresh, upper-cased copy of `s`. Caller owns it.
fn shout(a: std.mem.Allocator, s: []const u8) ![]u8 {
    // TODO: implement
    @panic("TODO");
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
