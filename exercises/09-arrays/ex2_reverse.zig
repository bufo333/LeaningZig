//! Chapter 09, exercise 2: reverse in place, through a pointer.
//! Run with:  zig test ex2_reverse.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// Reverse the array the pointer refers to. The caller sees the change.
fn reverse(xs: *[5]i32) void {
    _ = xs;
    // TODO: swap xs[i] and xs[j] while i < j
}

/// Return a reversed copy; the caller's array is untouched.
fn reversed(xs: [5]i32) [5]i32 {
    _ = xs;
    // TODO: copy, reverse the copy, return it
}

test "reverse mutates through the pointer" {
    var xs = [_]i32{ 1, 2, 3, 4, 5 };
    reverse(&xs);
    try std.testing.expectEqual([5]i32{ 5, 4, 3, 2, 1 }, xs);
}

test "reversed leaves the original alone" {
    const xs = [_]i32{ 1, 2, 3, 4, 5 };
    const ys = reversed(xs);
    try std.testing.expectEqual([5]i32{ 1, 2, 3, 4, 5 }, xs);
    try std.testing.expectEqual([5]i32{ 5, 4, 3, 2, 1 }, ys);
}

test "reversing twice is the identity" {
    var xs = [_]i32{ 9, -1, 0, 7, 3 };
    reverse(&xs);
    reverse(&xs);
    try std.testing.expect(std.mem.eql(i32, &xs, &[_]i32{ 9, -1, 0, 7, 3 }));
}
