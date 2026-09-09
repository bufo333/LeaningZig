//! Chapter 07, exercise 1: small pure functions.
//! Run with:  zig test ex1_helpers.zig
//! Goal: make every test pass without changing the tests.
//! Each body is a TODO. Remember: parameters cannot be reassigned.
const std = @import("std");

/// The larger of two i32 values.
fn max2(a: i32, b: i32) i32 {
    _ = a;
    _ = b;
    return 0; // TODO
}

/// Clamp x into the range lo..hi inclusive.
fn clamp(x: i32, lo: i32, hi: i32) i32 {
    _ = x;
    _ = lo;
    _ = hi;
    return 0; // TODO
}

/// True when the year is a leap year (divisible by 4, except centuries
/// unless divisible by 400).
fn isLeapYear(year: u16) bool {
    _ = year;
    return false; // TODO
}

/// Sum of the integers 1..n.
fn sumTo(n: u32) u32 {
    _ = n;
    return 0; // TODO
}

test "max2" {
    try std.testing.expectEqual(@as(i32, 7), max2(3, 7));
    try std.testing.expectEqual(@as(i32, 3), max2(3, -7));
}

test "clamp" {
    try std.testing.expectEqual(@as(i32, 0), clamp(-5, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), clamp(50, 0, 10));
    try std.testing.expectEqual(@as(i32, 4), clamp(4, 0, 10));
}

test "isLeapYear" {
    try std.testing.expect(isLeapYear(2024));
    try std.testing.expect(!isLeapYear(2023));
    try std.testing.expect(!isLeapYear(1900));
    try std.testing.expect(isLeapYear(2000));
}

test "sumTo" {
    try std.testing.expectEqual(@as(u32, 0), sumTo(0));
    try std.testing.expectEqual(@as(u32, 55), sumTo(10));
}
