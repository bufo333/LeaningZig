//! Chapter 04, exercise 1: pick the smallest integer type that fits.
//! Run with:  zig test ex1_widths.zig
//! Goal: make every test pass by changing only the type annotations.
const std = @import("std");

const armor_points: u8 = 255; // 0..255, never negative
const temperature: i8 = -40; // -40..40
const day_index: u16 = 40_000; // 0..65535
const funds: i64 = -3_000_000_000; // can be hugely negative
const bit_flags: u3 = 0b101; // exactly three flags

test "each value fits and the width is minimal" {
    try std.testing.expectEqual(8, @bitSizeOf(@TypeOf(armor_points)));
    try std.testing.expectEqual(8, @bitSizeOf(@TypeOf(temperature)));
    try std.testing.expectEqual(16, @bitSizeOf(@TypeOf(day_index)));
    try std.testing.expectEqual(64, @bitSizeOf(@TypeOf(funds)));
    try std.testing.expectEqual(3, @bitSizeOf(@TypeOf(bit_flags)));
}

test "signedness" {
    try std.testing.expectEqual(.unsigned, @typeInfo(@TypeOf(armor_points)).int.signedness);
    try std.testing.expectEqual(.signed, @typeInfo(@TypeOf(temperature)).int.signedness);
    try std.testing.expectEqual(.signed, @typeInfo(@TypeOf(funds)).int.signedness);
}
