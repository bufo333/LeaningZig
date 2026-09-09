//! Chapter 29, exercise 4: damage rolls with @Vector.
//! Run with:  zig test ex4_vector.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

pub const V = @Vector(8, u16);

/// Armor after damage, per location, never below zero.
pub fn applyDamage(armor: V, damage: V) V {
    // `-|` is saturating subtraction and works element-wise on vectors,
    // so no lane can wrap below zero. @select then shows the same idea
    // spelled out with a mask.
    const zero: V = @splat(0);
    const would_break = damage >= armor;
    return @select(u16, would_break, zero, armor -| damage);
}

/// True if any location was reduced to zero.
pub fn anyBreached(armor: V) bool {
    const zero: V = @splat(0);
    return @reduce(.Or, armor == zero);
}

/// Total armor remaining.
pub fn total(armor: V) u32 {
    var t: u32 = 0;
    const arr: [8]u16 = armor;
    for (arr) |a| t += a;
    return t;
}

/// Index of the weakest location (first one on ties).
pub fn weakest(armor: V) usize {
    const min = @reduce(.Min, armor);
    const arr: [8]u16 = armor;
    for (arr, 0..) |a, i| if (a == min) return i;
    unreachable;
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
