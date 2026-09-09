//! Chapter 08, exercise 2: pick the right assertion.
//! Run with:  zig test ex2_pick_assertion.zig
//! Goal: replace every `expect(...)` with the most specific assertion that fits,
//! so that a failure prints a useful message. All tests must still pass.
const std = @import("std");

const ParseError = error{ Empty, NotADigit };

fn digit(s: []const u8) ParseError!u8 {
    if (s.len == 0) return error.Empty;
    const c = s[0];
    if (c < '0' or c > '9') return error.NotADigit;
    return c - '0';
}

fn shout(buf: []u8, word: []const u8) []const u8 {
    for (word, 0..) |c, i| buf[i] = std.ascii.toUpper(c);
    return buf[0..word.len];
}

fn firstTwo(xs: []const u32) []const u32 {
    return xs[0..2];
}

test "digit parses a single digit" {
    try std.testing.expectEqual(@as(u8, 7), try digit("7"));
}

test "digit rejects empty input" {
    try std.testing.expectError(error.Empty, digit(""));
}

test "digit rejects letters" {
    try std.testing.expectError(error.NotADigit, digit("x"));
}

test "shout upper-cases" {
    var buf: [16]u8 = undefined;
    try std.testing.expectEqualStrings("LANCE", shout(&buf, "lance"));
}

test "firstTwo slices" {
    const data = [_]u32{ 5, 6, 7 };
    try std.testing.expectEqualSlices(u32, &[_]u32{ 5, 6 }, firstTwo(&data));
}
