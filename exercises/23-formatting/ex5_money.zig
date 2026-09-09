//! Chapter 23, exercise 5: money with thousands separators, like IRON LEDGER's.
//! Run with:  zig test ex5_money.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// -1234567 -> "-1,234,567". The caller owns the result.
fn money(gpa: std.mem.Allocator, v: i64) ![]u8 {
    _ = gpa;
    _ = v;
    // TODO
}

/// "1,234,567" or "-1,234,567" -> i64. Commas are optional; anything else is an error.
fn parseMoney(text: []const u8) !i64 {
    _ = text;
    // TODO
}

fn check(expected: []const u8, v: i64) !void {
    const s = try money(std.testing.allocator, v);
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings(expected, s);
    try std.testing.expectEqual(v, try parseMoney(s));
}

test "money" {
    try check("0", 0);
    try check("999", 999);
    try check("1,000", 1000);
    try check("1,234,567", 1234567);
    try check("-950", -950);
    try check("-1,234,567", -1234567);
}

test "parse rejects junk" {
    try std.testing.expectError(error.InvalidCharacter, parseMoney("1,2x3"));
    try std.testing.expectEqual(@as(i64, 5000), try parseMoney("5000"));
}
