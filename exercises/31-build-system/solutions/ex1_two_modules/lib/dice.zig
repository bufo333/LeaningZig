//! Chapter 31, exercise 1: the "dice" library module.
//! Run with:  zig build test   (inside ex1_two_modules/)
const std = @import("std");

pub const Roll = struct { total: u8, dice: [2]u8 };

/// Deterministic 2d6 from a seed, so tests can check exact values.
pub fn roll2d6(seed: u64) Roll {
    var prng = std.Random.DefaultPrng.init(seed);
    const r = prng.random();
    const a = r.intRangeAtMost(u8, 1, 6);
    const b = r.intRangeAtMost(u8, 1, 6);
    return .{ .total = a + b, .dice = .{ a, b } };
}

pub fn isSnakeEyes(r: Roll) bool {
    return r.dice[0] == 1 and r.dice[1] == 1;
}

test "range" {
    for (0..200) |seed| {
        const r = roll2d6(seed);
        try std.testing.expect(r.total >= 2 and r.total <= 12);
        try std.testing.expectEqual(r.total, r.dice[0] + r.dice[1]);
    }
}

test "deterministic" {
    try std.testing.expectEqual(roll2d6(3025).total, roll2d6(3025).total);
}
