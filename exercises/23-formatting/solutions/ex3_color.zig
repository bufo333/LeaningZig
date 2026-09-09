//! Chapter 23, exercise 3: parse and print hex colours.
//! Run with:  zig test ex3_color.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Rgb = struct { r: u8, g: u8, b: u8 };

/// "#ff8800" or "ff8800" -> Rgb. Case-insensitive.
fn parseColor(text: []const u8) !Rgb {
    const hex = if (text.len > 0 and text[0] == '#') text[1..] else text;
    if (hex.len != 6) return error.WrongLength;
    return .{
        .r = try std.fmt.parseUnsigned(u8, hex[0..2], 16),
        .g = try std.fmt.parseUnsigned(u8, hex[2..4], 16),
        .b = try std.fmt.parseUnsigned(u8, hex[4..6], 16),
    };
}

/// Rgb -> "#ff8800", lower case, always six digits.
fn formatColor(buf: []u8, c: Rgb) ![]u8 {
    return std.fmt.bufPrint(buf, "#{x:0>2}{x:0>2}{x:0>2}", .{ c.r, c.g, c.b });
}

test "parse" {
    try std.testing.expectEqual(Rgb{ .r = 255, .g = 136, .b = 0 }, try parseColor("#ff8800"));
    try std.testing.expectEqual(Rgb{ .r = 255, .g = 136, .b = 0 }, try parseColor("FF8800"));
    try std.testing.expectError(error.WrongLength, parseColor("#fff"));
    try std.testing.expectError(error.InvalidCharacter, parseColor("#gg0000"));
}

test "format round trip" {
    var buf: [8]u8 = undefined;
    try std.testing.expectEqualStrings("#0a0b0c", try formatColor(&buf, .{ .r = 10, .g = 11, .b = 12 }));
    const c = try parseColor("#12abEF");
    try std.testing.expectEqualStrings("#12abef", try formatColor(&buf, c));
}
