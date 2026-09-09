//! Chapter 18, exercise 1: swap through pointers.
//! Run with:  zig test ex1_swap.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Exchange the values behind the two pointers.
fn swap(a: *i32, b: *i32) void {
    const tmp = a.*;
    a.* = b.*;
    b.* = tmp;
}

/// Add `by` to the value behind `p`.
fn bump(p: *u32, by: u32) void {
    p.* += by;
}

/// Read-only: a pointer to const may be read but never written through.
fn twice(p: *const u32) u32 {
    return p.* * 2;
}

test "swap" {
    var x: i32 = 1;
    var y: i32 = 2;
    swap(&x, &y);
    try std.testing.expectEqual(@as(i32, 2), x);
    try std.testing.expectEqual(@as(i32, 1), y);
}

test "bump and twice" {
    var n: u32 = 5;
    bump(&n, 3);
    try std.testing.expectEqual(@as(u32, 8), n);
    try std.testing.expectEqual(@as(u32, 16), twice(&n));
    const frozen: u32 = 21;
    try std.testing.expectEqual(@as(u32, 42), twice(&frozen));
}
