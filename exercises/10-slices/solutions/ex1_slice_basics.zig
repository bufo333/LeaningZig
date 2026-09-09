//! Chapter 10, exercise 1: slice basics.
//! Run with:  zig test ex1_slice_basics.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// The last `n` elements of `xs`. If n is larger than xs.len, return all of xs.
fn lastN(xs: []const u8, n: usize) []const u8 {
    if (n >= xs.len) return xs;
    return xs[xs.len - n ..];
}

/// Everything except the first and last element. Empty if xs has fewer than 3.
fn inner(xs: []const u8) []const u8 {
    if (xs.len < 3) return xs[0..0];
    return xs[1 .. xs.len - 1];
}

/// Split `xs` in half. The first half gets the extra element when odd.
fn halves(xs: []const u8) [2][]const u8 {
    const mid = (xs.len + 1) / 2;
    return .{ xs[0..mid], xs[mid..] };
}

test "lastN" {
    const d = [_]u8{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqualSlices(u8, &[_]u8{ 4, 5 }, lastN(&d, 2));
    try std.testing.expectEqualSlices(u8, &d, lastN(&d, 9));
    try std.testing.expectEqual(@as(usize, 0), lastN(&d, 0).len);
}

test "inner" {
    const d = [_]u8{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqualSlices(u8, &[_]u8{ 2, 3, 4 }, inner(&d));
    try std.testing.expectEqual(@as(usize, 0), inner(d[0..2]).len);
}

test "halves" {
    const d = [_]u8{ 1, 2, 3, 4, 5 };
    const h = halves(&d);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 1, 2, 3 }, h[0]);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 4, 5 }, h[1]);
    const e = halves(d[0..0]);
    try std.testing.expectEqual(@as(usize, 0), e[0].len + e[1].len);
}
