//! Chapter 08, exercise 3: read a failure, fix the bug.
//! Run with:  zig test ex3_fix_the_bug.zig
//! Goal: the tests are correct; the functions have bugs. Read the failure output,
//! find each bug and fix it. Do not edit the tests.
const std = @import("std");

/// Sum of the first n positive integers: 1 + 2 + ... + n.
fn triangle(n: u32) u32 {
    var total: u32 = 0;
    var i: u32 = 1;
    while (i <= n) : (i += 1) total += i;
    return total;
}

/// Number of characters in s that equal c.
fn countChar(s: []const u8, c: u8) usize {
    var n: usize = 0;
    for (s) |ch| {
        if (ch == c) n += 1;
    }
    return n;
}

/// Clamp x into [lo, hi].
fn clamp(x: i32, lo: i32, hi: i32) i32 {
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
}

test "triangle numbers" {
    try std.testing.expectEqual(@as(u32, 0), triangle(0));
    try std.testing.expectEqual(@as(u32, 1), triangle(1));
    try std.testing.expectEqual(@as(u32, 10), triangle(4));
    try std.testing.expectEqual(@as(u32, 5050), triangle(100));
}

test "countChar" {
    try std.testing.expectEqual(@as(usize, 3), countChar("banana", 'a'));
    try std.testing.expectEqual(@as(usize, 0), countChar("banana", 'z'));
    try std.testing.expectEqual(@as(usize, 0), countChar("", 'a'));
}

test "clamp" {
    try std.testing.expectEqual(@as(i32, 5), clamp(5, 0, 10));
    try std.testing.expectEqual(@as(i32, 0), clamp(-3, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), clamp(42, 0, 10));
}
