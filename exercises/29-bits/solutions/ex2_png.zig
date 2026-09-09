//! Chapter 29, exercise 2: parse a PNG header by hand.
//! Run with:  zig test ex2_png.zig
//! Goal: make every test pass without changing the tests.
//! Compare with the real decoder in game/src/tui/png.zig.
const std = @import("std");

pub const Error = error{ NotPng, Corrupt, Unsupported };

pub const ColorType = enum(u8) { grey = 0, rgb = 2, palette = 3, grey_alpha = 4, rgba = 6 };

pub const Header = struct {
    width: u32,
    height: u32,
    bit_depth: u8,
    color: ColorType,
    interlaced: bool,

    /// Bytes per pixel for 8-bit images.
    pub fn channels(self: Header) u8 {
        return switch (self.color) {
            .grey, .palette => 1,
            .grey_alpha => 2,
            .rgb => 3,
            .rgba => 4,
        };
    }
};

const signature = "\x89PNG\r\n\x1a\n";

pub fn isPng(bytes: []const u8) bool {
    return bytes.len >= 8 and std.mem.eql(u8, bytes[0..8], signature);
}

/// Parse the 8-byte signature and the IHDR chunk that must follow it:
///   4 bytes length (big-endian, must be 13)
///   4 bytes type ("IHDR")
///   13 bytes data: width u32, height u32, depth u8, color u8, compression u8,
///                  filter u8, interlace u8
///   4 bytes CRC (ignored here)
pub fn parseHeader(bytes: []const u8) Error!Header {
    if (!isPng(bytes)) return error.NotPng;
    if (bytes.len < 8 + 8 + 13 + 4) return error.Corrupt;
    const len = std.mem.readInt(u32, bytes[8..12], .big);
    if (len != 13) return error.Corrupt;
    if (!std.mem.eql(u8, bytes[12..16], "IHDR")) return error.Corrupt;
    const d = bytes[16..29];
    const color_raw = d[9];
    const color: ColorType = switch (color_raw) {
        0 => .grey,
        2 => .rgb,
        3 => .palette,
        4 => .grey_alpha,
        6 => .rgba,
        else => return error.Corrupt,
    };
    const depth = d[8];
    if (depth != 8) return error.Unsupported;
    if (d[10] != 0 or d[11] != 0) return error.Corrupt;
    return .{
        .width = std.mem.readInt(u32, d[0..4], .big),
        .height = std.mem.readInt(u32, d[4..8], .big),
        .bit_depth = depth,
        .color = color,
        .interlaced = d[12] == 1,
    };
}

/// Build a header blob for tests: signature + IHDR chunk with a fake CRC.
fn makePng(w: u32, h: u32, depth: u8, color: u8, interlace: u8) [33]u8 {
    var out: [33]u8 = undefined;
    @memcpy(out[0..8], signature);
    std.mem.writeInt(u32, out[8..12], 13, .big);
    @memcpy(out[12..16], "IHDR");
    std.mem.writeInt(u32, out[16..20], w, .big);
    std.mem.writeInt(u32, out[20..24], h, .big);
    out[24] = depth;
    out[25] = color;
    out[26] = 0;
    out[27] = 0;
    out[28] = interlace;
    @memset(out[29..33], 0);
    return out;
}

test "a 4x3 RGB image" {
    const png = makePng(4, 3, 8, 2, 0);
    const hdr = try parseHeader(&png);
    try std.testing.expectEqual(@as(u32, 4), hdr.width);
    try std.testing.expectEqual(@as(u32, 3), hdr.height);
    try std.testing.expectEqual(ColorType.rgb, hdr.color);
    try std.testing.expectEqual(@as(u8, 3), hdr.channels());
    try std.testing.expect(!hdr.interlaced);
}

test "big-endian really matters" {
    const png = makePng(256, 1, 8, 6, 1);
    const hdr = try parseHeader(&png);
    try std.testing.expectEqual(@as(u32, 256), hdr.width);
    try std.testing.expectEqual(@as(u8, 4), hdr.channels());
    try std.testing.expect(hdr.interlaced);
}

test "rejections" {
    try std.testing.expectError(error.NotPng, parseHeader("hello"));
    var bad = makePng(1, 1, 8, 2, 0);
    bad[13] = 'X';
    try std.testing.expectError(error.Corrupt, parseHeader(&bad));
    try std.testing.expectError(error.Unsupported, parseHeader(&makePng(1, 1, 16, 2, 0)));
    try std.testing.expectError(error.Corrupt, parseHeader(&makePng(1, 1, 8, 5, 0)));
}
