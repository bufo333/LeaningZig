//! Chapter 04, exercise 4: a bit-flag set for unit status.
//! Run with:  zig test ex4_bits.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const damaged: u3 = 0;
const low_ammo: u3 = 1;
const pilot_injured: u3 = 2;

/// Return `flags` with bit `bit` turned on.
fn set(flags: u8, bit: u3) u8 {
    return flags | (@as(u8, 1) << bit);
}

/// Return `flags` with bit `bit` turned off.
fn clear(flags: u8, bit: u3) u8 {
    return flags & ~(@as(u8, 1) << bit);
}

/// Is bit `bit` on in `flags`?
fn isSet(flags: u8, bit: u3) bool {
    return (flags >> bit) & 1 == 1;
}

/// How many bits are on?
fn count(flags: u8) u8 {
    return @popCount(flags);
}

test "set and test" {
    var f: u8 = 0;
    f = set(f, low_ammo);
    try std.testing.expect(isSet(f, low_ammo));
    try std.testing.expect(!isSet(f, damaged));
    try std.testing.expectEqual(@as(u8, 0b010), f);
}

test "clear" {
    var f: u8 = 0b111;
    f = clear(f, pilot_injured);
    try std.testing.expectEqual(@as(u8, 0b011), f);
    f = clear(f, pilot_injured); // clearing twice is harmless
    try std.testing.expectEqual(@as(u8, 0b011), f);
}

test "count" {
    try std.testing.expectEqual(@as(u8, 0), count(0));
    try std.testing.expectEqual(@as(u8, 3), count(0b111));
    try std.testing.expectEqual(@as(u8, 8), count(0xFF));
}
