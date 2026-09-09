//! Chapter 09, exercise 1: array statistics.
//! Run with:  zig test ex1_stats.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// The heaviest value in the array.
fn heaviest(tons: [4]u8) u8 {
    var best: u8 = 0;
    for (tons) |t| {
        if (t > best) best = t;
    }
    return best;
}

/// The sum of all values. Note the wider result type: four u8 can exceed 255.
fn total(tons: [4]u8) u32 {
    var sum: u32 = 0;
    for (tons) |t| sum += t;
    return sum;
}

/// Index of the first element equal to `needle`, or the array length if absent.
fn indexOf(tons: [4]u8, needle: u8) usize {
    for (tons, 0..) |t, i| {
        if (t == needle) return i;
    }
    return tons.len;
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
