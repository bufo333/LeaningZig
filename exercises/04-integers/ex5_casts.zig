//! Chapter 04, exercise 5: casts that mean what they say.
//! Run with:  zig test ex5_casts.zig
//! Goal: make every test pass without changing the tests.
//! Each body is a TODO. Use exactly one of @as, @truncate, @bitCast, @intCast
//! per function, whichever says what the doc comment means.
const std = @import("std");

/// Total tonnage of a lance of `count` units at `each` tons, as a u32.
/// Both inputs are u8, so the product must be widened before multiplying.
fn lanceTonnage(count: u8, each: u8) u32 {
    _ = count;
    _ = each;
    return 0; // TODO
}

/// The low byte of a 32-bit colour value (the blue channel of 0xRRGGBB).
fn blue(rgb: u32) u8 {
    _ = rgb;
    return 0; // TODO
}

/// Reinterpret the bits of a signed byte as unsigned, without changing them.
fn rawByte(x: i8) u8 {
    _ = x;
    return 0; // TODO
}

/// Convert an index (usize) into a u16 row number. Callers promise it fits.
fn rowNumber(index: usize) u16 {
    _ = index;
    return 0; // TODO
}

test "lanceTonnage does not overflow" {
    try std.testing.expectEqual(@as(u32, 400), lanceTonnage(4, 100));
    try std.testing.expectEqual(@as(u32, 65_025), lanceTonnage(255, 255));
}

test "blue keeps the low byte" {
    try std.testing.expectEqual(@as(u8, 0x56), blue(0x123456));
    try std.testing.expectEqual(@as(u8, 0xFF), blue(0x0000FF));
}

test "rawByte keeps the bits" {
    try std.testing.expectEqual(@as(u8, 255), rawByte(-1));
    try std.testing.expectEqual(@as(u8, 128), rawByte(-128));
    try std.testing.expectEqual(@as(u8, 5), rawByte(5));
}

test "rowNumber narrows" {
    try std.testing.expectEqual(@as(u16, 12), rowNumber(12));
    try std.testing.expectEqual(@as(u16, 65_535), rowNumber(65_535));
}
