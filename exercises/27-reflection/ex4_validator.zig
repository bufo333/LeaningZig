//! Chapter 27, exercise 4: a tuning-table validator.
//! Run with:  zig test ex4_validator.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Tuning = struct {
    person: struct { fatigue_tired: u8, exhausted_fatigue: u8, morale_delta: i8 },
    market: struct { fab_cost_bp: u32, fab_days: u32, rarity_target: [3]u8 },
    battle: struct { salvage_bp: u32, retreat_chance: ?f32 },
};

pub const stock = Tuning{
    .person = .{ .fatigue_tired = 30, .exhausted_fatigue = 70, .morale_delta = -2 },
    .market = .{ .fab_cost_bp = 12_000, .fab_days = 14, .rarity_target = .{ 5, 3, 1 } },
    .battle = .{ .salvage_bp = 2_500, .retreat_chance = 0.25 },
};

pub const Problem = error{ Zero, TooManyBasisPoints, BadFraction };

/// Walk `value` recursively. Rules:
///  - unsigned ints must be > 0                     (error.Zero)
///  - names ending in _bp must be <= 100_000        (error.TooManyBasisPoints)
///  - floats must be within 0.0 ... 1.0 inclusive   (error.BadFraction)
///  - signed ints are free, optionals check the payload when present,
///    arrays check every element, structs recurse into every field.
/// On failure, print "bad knob: <dotted.path>" to stderr before returning.
pub fn validate(comptime T: type, value: T, comptime path: []const u8) Problem!void {
    // TODO: implement this function.
    @panic("TODO");
}

fn fail(path: []const u8, err: Problem) Problem!void {
    std.debug.print("bad knob: {s}\n", .{path});
    return err;
}

test "stock tuning passes" {
    try validate(Tuning, stock, "t");
}

test "zero in a nested struct" {
    var t = stock;
    t.market.fab_days = 0;
    try std.testing.expectError(error.Zero, validate(Tuning, t, "t"));
}

test "basis points too large" {
    var t = stock;
    t.battle.salvage_bp = 200_000;
    try std.testing.expectError(error.TooManyBasisPoints, validate(Tuning, t, "t"));
}

test "zero inside an array element" {
    var t = stock;
    t.market.rarity_target[2] = 0;
    try std.testing.expectError(error.Zero, validate(Tuning, t, "t"));
}

test "optional float out of range, and null is fine" {
    var t = stock;
    t.battle.retreat_chance = 1.5;
    try std.testing.expectError(error.BadFraction, validate(Tuning, t, "t"));
    t.battle.retreat_chance = null;
    try validate(Tuning, t, "t");
}

test "signed ints may be negative" {
    var t = stock;
    t.person.morale_delta = -100;
    try validate(Tuning, t, "t");
}
