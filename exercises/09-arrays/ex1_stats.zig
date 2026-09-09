//! Chapter 09, exercise 1: array statistics.
//! Run with:  zig test ex1_stats.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// The heaviest value in the array.
fn heaviest(tons: [4]u8) u8 {
    _ = tons;
    // TODO
}

/// The sum of all values. Think about the result type: four u8 can exceed 255.
fn total(tons: [4]u8) u32 {
    _ = tons;
    // TODO
}

/// Index of the first element equal to `needle`, or the array length if absent.
fn indexOf(tons: [4]u8, needle: u8) usize {
    _ = tons;
    _ = needle;
    // TODO
}

test "heaviest" {
    try std.testing.expectEqual(@as(u8, 70), heaviest(.{ 55, 65, 70, 50 }));
    try std.testing.expectEqual(@as(u8, 100), heaviest(.{ 100, 20, 20, 20 }));
}

test "total does not overflow" {
    try std.testing.expectEqual(@as(u32, 240), total(.{ 55, 65, 70, 50 }));
    try std.testing.expectEqual(@as(u32, 1020), total(.{ 255, 255, 255, 255 }));
}

test "indexOf" {
    const lance = [_]u8{ 55, 65, 70, 50 };
    try std.testing.expectEqual(@as(usize, 2), indexOf(lance, 70));
    try std.testing.expectEqual(@as(usize, 4), indexOf(lance, 99));
}
