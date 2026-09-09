//! Chapter 11, exercise 3: building strings into a buffer.
//! Run with:  zig test ex3_build.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// "Last, First" into buf. Hint: one bufPrint.
fn fullName(buf: []u8, first: []const u8, last: []const u8) ![]const u8 {
    _ = buf;
    _ = first;
    _ = last;
    // TODO
}

/// The words of `line` joined by a single space, upper-cased, into buf.
/// Hint: std.Io.Writer.fixed(buf) gives you a writer with writeByte; finish
/// with w.buffered().
fn shoutWords(buf: []u8, line: []const u8) ![]const u8 {
    _ = buf;
    _ = line;
    // TODO
}

/// A C-bills amount with thousands separators: 1234567 -> "1,234,567".
/// Hint: print the digits into a small scratch array first, then copy them
/// out with commas.
fn money(buf: []u8, amount: u64) ![]const u8 {
    _ = buf;
    _ = amount;
    // TODO
}

test "fullName" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings("Allard, Kai", try fullName(&buf, "Kai", "Allard"));
}

test "fullName refuses a too-small buffer" {
    var buf: [4]u8 = undefined;
    try std.testing.expectError(error.NoSpaceLeft, fullName(&buf, "Kai", "Allard"));
}

test "shoutWords" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqualStrings("HIRE KAI NOW", try shoutWords(&buf, "  hire   kai now "));
    try std.testing.expectEqualStrings("", try shoutWords(&buf, ""));
}

test "money" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings("0", try money(&buf, 0));
    try std.testing.expectEqualStrings("999", try money(&buf, 999));
    try std.testing.expectEqualStrings("1,000", try money(&buf, 1000));
    try std.testing.expectEqualStrings("1,234,567", try money(&buf, 1234567));
}
