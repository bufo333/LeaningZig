//! Chapter 16, exercise 2: catch, and switching on an error.
//! Run with:  zig test ex2_catch.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

const ParseError = error{ Empty, NotANumber, TooBig };

fn parsePercent(text: []const u8) ParseError!u8 {
    if (text.len == 0) return error.Empty;
    const n = std.fmt.parseInt(u32, text, 10) catch return error.NotANumber;
    if (n > 100) return error.TooBig;
    return @intCast(n);
}

/// Parse, or fall back to `default`. One line with `catch`.
fn parseOr(text: []const u8, default: u8) u8 {
    // TODO: implement
    @panic("TODO");
}

/// A sentence for each error. The switch must be exhaustive.
fn errorText(err: ParseError) []const u8 {
    // TODO: implement
    @panic("TODO");
}

/// Parse and, on failure, return the sentence instead of the number.
/// Return type: a tagged union so the caller can tell which happened.
const Outcome = union(enum) { value: u8, message: []const u8 };

fn describe(text: []const u8) Outcome {
    // TODO: implement
    @panic("TODO");
}

test "parseOr" {
    try std.testing.expectEqual(@as(u8, 40), parseOr("40", 5));
    try std.testing.expectEqual(@as(u8, 5), parseOr("", 5));
    try std.testing.expectEqual(@as(u8, 5), parseOr("x", 5));
}

test "errorText" {
    try std.testing.expectEqualStrings("you gave me nothing", errorText(error.Empty));
    try std.testing.expectEqualStrings("a percentage between 0 and 100", errorText(error.TooBig));
}

test "describe" {
    try std.testing.expectEqual(@as(u8, 12), describe("12").value);
    try std.testing.expectEqualStrings("that is not a number", describe("twelve").message);
}
