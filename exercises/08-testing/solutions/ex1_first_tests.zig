//! Chapter 08, exercise 1: your first test file.
//! Run with:  zig test ex1_first_tests.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Returns the larger of two integers.
fn max(a: i32, b: i32) i32 {
    return if (a > b) a else b;
}

/// Returns true when n is even.
fn isEven(n: i32) bool {
    return @rem(n, 2) == 0;
}

test "max picks the larger" {
    try std.testing.expectEqual(@as(i32, 7), max(3, 7));
    try std.testing.expectEqual(@as(i32, 7), max(7, 3));
    try std.testing.expectEqual(@as(i32, -1), max(-1, -5));
}

test "isEven" {
    try std.testing.expect(isEven(0));
    try std.testing.expect(isEven(10));
    try std.testing.expect(!isEven(7));
    try std.testing.expect(isEven(-4));
}
