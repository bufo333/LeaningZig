//! Chapter 34, exercise 2: a dice roller.
//! Run with:  zig test ex2_dice.zig
//! Goal: implement `roll` and `roll2d6`, then make every test pass
//! without changing the tests.

const std = @import("std");

/// Roll `count` dice with `sides` sides each and return the total.
pub fn roll(r: std.Random, count: u8, sides: u8) u32 {
    std.debug.assert(sides >= 1);
    var total: u32 = 0;
    for (0..count) |_| total += r.intRangeAtMost(u8, 1, sides);
    return total;
}

/// The BattleTech die roll.
pub fn roll2d6(r: std.Random) u32 {
    return roll(r, 2, 6);
}

test "one die stays in range" {
    var prng = std.Random.DefaultPrng.init(1);
    const r = prng.random();
    for (0..1000) |_| {
        const v = roll(r, 1, 6);
        try std.testing.expect(v >= 1 and v <= 6);
    }
}

test "2d6 stays in range and hits both ends" {
    var prng = std.Random.DefaultPrng.init(2);
    const r = prng.random();
    var seen_2 = false;
    var seen_12 = false;
    for (0..5000) |_| {
        const v = roll2d6(r);
        try std.testing.expect(v >= 2 and v <= 12);
        if (v == 2) seen_2 = true;
        if (v == 12) seen_12 = true;
    }
    try std.testing.expect(seen_2 and seen_12);
}

test "2d6 averages close to 7" {
    var prng = std.Random.DefaultPrng.init(3);
    const r = prng.random();
    var total: u64 = 0;
    const n = 20_000;
    for (0..n) |_| total += roll2d6(r);
    const avg: f64 = @as(f64, @floatFromInt(total)) / n;
    try std.testing.expect(avg > 6.8 and avg < 7.2);
}

test "same seed, same rolls" {
    var a = std.Random.DefaultPrng.init(99);
    var b = std.Random.DefaultPrng.init(99);
    for (0..100) |_| {
        try std.testing.expectEqual(roll2d6(a.random()), roll2d6(b.random()));
    }
}
