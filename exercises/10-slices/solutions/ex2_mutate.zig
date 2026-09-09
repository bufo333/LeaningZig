//! Chapter 10, exercise 2: mutating through slices.
//! Run with:  zig test ex2_mutate.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Add `delta` to every element, saturating at 255.
fn heal(hp: []u8, delta: u8) void {
    for (hp) |*h| h.* +|= delta;
}

/// Set every element that is below `floor` to `floor`.
fn raiseFloor(xs: []i32, floor: i32) void {
    for (xs) |*x| {
        if (x.* < floor) x.* = floor;
    }
}

/// Copy `src` into the front of `dst` and fill the rest with `pad`.
/// Returns dst.len. Panics if src is longer than dst (that is a caller bug).
fn padCopy(dst: []u8, src: []const u8, pad: u8) usize {
    @memcpy(dst[0..src.len], src);
    @memset(dst[src.len..], pad);
    return dst.len;
}

test "heal saturates" {
    var hp = [_]u8{ 250, 10, 0 };
    heal(&hp, 10);
    try std.testing.expectEqual([3]u8{ 255, 20, 10 }, hp);
}

test "raiseFloor" {
    var xs = [_]i32{ -5, 0, 5 };
    raiseFloor(&xs, 0);
    try std.testing.expectEqual([3]i32{ 0, 0, 5 }, xs);
    raiseFloor(xs[2..], 100); // only the tail
    try std.testing.expectEqual([3]i32{ 0, 0, 100 }, xs);
}

test "padCopy" {
    var buf: [8]u8 = undefined;
    const n = padCopy(&buf, "mek", ' ');
    try std.testing.expectEqual(@as(usize, 8), n);
    try std.testing.expectEqualStrings("mek     ", &buf);
    _ = padCopy(buf[4..], "ab", '-');
    try std.testing.expectEqualStrings("mek ab--", &buf);
}
