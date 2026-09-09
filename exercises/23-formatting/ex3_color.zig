//! Chapter 23, exercise 3: parse and print hex colours.
//! Run with:  zig test ex3_color.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Rgb = struct { r: u8, g: u8, b: u8 };

/// "#ff8800" or "ff8800" -> Rgb. Case-insensitive.
fn parseColor(text: []const u8) !Rgb {
    _ = text;
    // TODO
}

/// Rgb -> "#ff8800", lower case, always six digits.
fn formatColor(buf: []u8, c: Rgb) ![]u8 {
    _ = buf;
    _ = c;
    // TODO
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
