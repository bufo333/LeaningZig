//! Chapter 10, exercise 3: searching and windows.
//! Run with:  zig test ex3_search.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// Index of the largest element, or null when the slice is empty.
fn argMax(xs: []const i32) ?usize {
    _ = xs;
    // TODO
}

/// The slice of `xs` that starts at the first element >= `threshold`.
/// Empty slice at the end if nothing qualifies. Hint: xs[xs.len..] is empty.
fn from(xs: []const i32, threshold: i32) []const i32 {
    _ = xs;
    _ = threshold;
    // TODO
}

/// The largest sum of any `w` consecutive elements. Requires w <= xs.len and w > 0.
fn bestWindow(xs: []const i32, w: usize) i32 {
    _ = xs;
    _ = w;
    // TODO: slide a window xs[start .. start + w]
}

test "argMax" {
    try std.testing.expectEqual(@as(?usize, 2), argMax(&[_]i32{ 1, 5, 9, 3 }));
    try std.testing.expectEqual(@as(?usize, 0), argMax(&[_]i32{ 9, 9, 9 }));
    try std.testing.expectEqual(@as(?usize, null), argMax(&[_]i32{}));
}

test "from" {
    const d = [_]i32{ 1, 4, 2, 8, 3 };
    try std.testing.expectEqualSlices(i32, &[_]i32{ 4, 2, 8, 3 }, from(&d, 4));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 8, 3 }, from(&d, 5));
    try std.testing.expectEqual(@as(usize, 0), from(&d, 100).len);
}

test "bestWindow" {
    const d = [_]i32{ 1, 4, 2, 8, 3 };
    try std.testing.expectEqual(@as(i32, 8), bestWindow(&d, 1));
    try std.testing.expectEqual(@as(i32, 11), bestWindow(&d, 2));
    try std.testing.expectEqual(@as(i32, 18), bestWindow(&d, 5));
}
