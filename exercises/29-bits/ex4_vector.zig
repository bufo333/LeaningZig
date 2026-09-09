//! Chapter 29, exercise 4: damage rolls with @Vector.
//! Run with:  zig test ex4_vector.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const V = @Vector(8, u16);

/// Armor after damage, per location, never below zero.
pub fn applyDamage(armor: V, damage: V) V {
    // TODO: implement this function.
    @panic("TODO");
}

/// True if any location was reduced to zero.
pub fn anyBreached(armor: V) bool {
    // TODO: implement this function.
    @panic("TODO");
}

/// Total armor remaining.
pub fn total(armor: V) u32 {
    // TODO: implement this function.
    @panic("TODO");
}

/// Index of the weakest location (first one on ties).
pub fn weakest(armor: V) usize {
    // TODO: implement this function.
    @panic("TODO");
}

test "damage saturates at zero" {
    const armor: V = .{ 10, 10, 10, 10, 10, 10, 10, 10 };
    const dmg: V = .{ 3, 0, 12, 10, 0, 0, 0, 1 };
    const after = applyDamage(armor, dmg);
    const expected: [8]u16 = .{ 7, 10, 0, 0, 10, 10, 10, 9 };
    try std.testing.expectEqual(expected, @as([8]u16, after));
    try std.testing.expect(anyBreached(after));
    try std.testing.expect(!anyBreached(armor));
}

test "totals and weakest" {
    const armor: V = .{ 8, 6, 9, 6, 7, 7, 7, 7 };
    try std.testing.expectEqual(@as(u32, 57), total(armor));
    try std.testing.expectEqual(@as(usize, 1), weakest(armor));
}
