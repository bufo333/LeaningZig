//! Chapter 21, exercise 1: build a list, hand it back as a slice.
//! Run with:  zig test ex1_squares.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO.
const std = @import("std");

/// Return the squares 0*0, 1*1, ... (n-1)*(n-1) as a slice the caller owns.
/// Reserve capacity up front so there is exactly one allocation.
fn squaresUpTo(gpa: std.mem.Allocator, n: u32) ![]u32 {
    _ = gpa;
    _ = n;
    // TODO: build an ArrayList(u32), fill it, return toOwnedSlice.
}

test "five squares" {
    const s = try squaresUpTo(std.testing.allocator, 5);
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 4, 9, 16 }, s);
}

test "zero squares is an empty slice, not an error" {
    const s = try squaresUpTo(std.testing.allocator, 0);
    defer std.testing.allocator.free(s);
    try std.testing.expectEqual(@as(usize, 0), s.len);
}
