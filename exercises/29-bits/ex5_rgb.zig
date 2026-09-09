//! Chapter 29, exercise 5: RGB565 pixels with masks and packed structs.
//! Run with:  zig test ex5_rgb.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Rgb565 = packed struct(u16) { b: u5, g: u6, r: u5 };

/// Pack 8-bit channels into 16 bits by dropping the low bits.
pub fn pack(r: u8, g: u8, b: u8) u16 {
    // TODO: implement this function.
    @panic("TODO");
}

/// Same thing with shifts and masks only, no struct.
pub fn packManual(r: u8, g: u8, b: u8) u16 {
    // TODO: implement this function.
    @panic("TODO");
}

/// Expand back to 8-bit channels (top bits replicated so 31 becomes 255).
pub fn unpack(px: u16) [3]u8 {
    // TODO: implement this function.
    @panic("TODO");
}

/// Write a pixel little-endian into a byte buffer at index i (2 bytes).
pub fn store(buf: []u8, i: usize, px: u16) void {
    // TODO: implement this function.
    @panic("TODO");
}
pub fn load(buf: []const u8, i: usize) u16 {
    // TODO: implement this function.
    @panic("TODO");
}

test "known colours" {
    try std.testing.expectEqual(@as(u16, 0xF800), pack(255, 0, 0));
    try std.testing.expectEqual(@as(u16, 0x07E0), pack(0, 255, 0));
    try std.testing.expectEqual(@as(u16, 0x001F), pack(0, 0, 255));
    try std.testing.expectEqual(@as(u16, 0xFFFF), pack(255, 255, 255));
}

test "both packers agree" {
    var r: u16 = 0;
    while (r < 256) : (r += 37) {
        const c: u8 = @intCast(r);
        try std.testing.expectEqual(packManual(c, 255 - c, c / 2), pack(c, 255 - c, c / 2));
    }
}

test "unpack expands full scale" {
    try std.testing.expectEqual([3]u8{ 255, 0, 0 }, unpack(0xF800));
    try std.testing.expectEqual([3]u8{ 255, 255, 255 }, unpack(0xFFFF));
    try std.testing.expectEqual([3]u8{ 0, 0, 0 }, unpack(0));
}

test "store and load bytes" {
    var buf: [4]u8 = undefined;
    store(&buf, 0, 0xF800);
    store(&buf, 1, 0x001F);
    try std.testing.expectEqual([4]u8{ 0x00, 0xF8, 0x1F, 0x00 }, buf);
    try std.testing.expectEqual(@as(u16, 0x001F), load(&buf, 1));
}
