//! Chapter 21, exercise 1: build a list, hand it back as a slice.
//! Run with:  zig test ex1_squares.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Return the squares 0*0, 1*1, ... (n-1)*(n-1) as a slice the caller owns.
fn squaresUpTo(gpa: std.mem.Allocator, n: u32) ![]u32 {
    var list: std.ArrayList(u32) = .empty;
    errdefer list.deinit(gpa);
    try list.ensureTotalCapacity(gpa, n);
    for (0..n) |i| {
        const v: u32 = @intCast(i);
        list.appendAssumeCapacity(v * v);
    }
    return list.toOwnedSlice(gpa);
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
