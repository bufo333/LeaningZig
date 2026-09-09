//! Chapter 16, exercise 1: an error set and a function that uses it.
//! Run with:  zig test ex1_parse.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const ParseError = error{ Empty, NotANumber, TooBig };

/// "40" -> 40. "" -> Empty. "forty" -> NotANumber. "140" -> TooBig.
fn parsePercent(text: []const u8) ParseError!u8 {
    if (text.len == 0) return error.Empty;
    const n = std.fmt.parseInt(u32, text, 10) catch return error.NotANumber;
    if (n > 100) return error.TooBig;
    return @intCast(n);
}

/// Parse two percentages and add them; propagate any error with `try`.
fn sumPercent(a: []const u8, b: []const u8) ParseError!u32 {
    const x = try parsePercent(a);
    const y = try parsePercent(b);
    return @as(u32, x) + y;
}

test "good input" {
    try std.testing.expectEqual(@as(u8, 40), try parsePercent("40"));
    try std.testing.expectEqual(@as(u8, 100), try parsePercent("100"));
}

test "bad input" {
    try std.testing.expectError(error.Empty, parsePercent(""));
    try std.testing.expectError(error.NotANumber, parsePercent("forty"));
    try std.testing.expectError(error.TooBig, parsePercent("140"));
}

test "try propagates" {
    try std.testing.expectEqual(@as(u32, 70), try sumPercent("30", "40"));
    try std.testing.expectError(error.TooBig, sumPercent("30", "400"));
    try std.testing.expectError(error.Empty, sumPercent("", "400"));
}
