//! Chapter 11, exercise 2: taking a command line apart.
//! Run with:  zig test ex2_tokens.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// The first whitespace-separated word, or "" when there is none.
fn verb(line: []const u8) []const u8 {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    return it.next() orelse "";
}

/// Number of whitespace-separated words.
fn wordCount(line: []const u8) usize {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    var n: usize = 0;
    while (it.next()) |_| n += 1;
    return n;
}

/// Everything after the first word, trimmed. "" if there is nothing.
fn args(line: []const u8) []const u8 {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    _ = it.next();
    return std.mem.trim(u8, it.rest(), " ");
}

/// Parse "YYYY-MM-DD" into three numbers. Any other shape is an error.
fn parseDate(s: []const u8) ![3]u16 {
    var it = std.mem.splitScalar(u8, s, '-');
    var out: [3]u16 = undefined;
    for (&out) |*slot| {
        const piece = it.next() orelse return error.BadDate;
        slot.* = try std.fmt.parseInt(u16, piece, 10);
    }
    if (it.next() != null) return error.BadDate;
    return out;
}

test "verb" {
    try std.testing.expectEqualStrings("hire", verb("hire Kai mekwarrior"));
    try std.testing.expectEqualStrings("day", verb("   day"));
    try std.testing.expectEqualStrings("", verb("   "));
}

test "wordCount" {
    try std.testing.expectEqual(@as(usize, 3), wordCount("hire Kai mekwarrior"));
    try std.testing.expectEqual(@as(usize, 3), wordCount("  hire   Kai  mekwarrior "));
    try std.testing.expectEqual(@as(usize, 0), wordCount(""));
}

test "args" {
    try std.testing.expectEqualStrings("Kai mekwarrior", args("hire Kai mekwarrior"));
    try std.testing.expectEqualStrings("1st Recon Lance", args("newlance   1st Recon Lance  "));
    try std.testing.expectEqualStrings("", args("day"));
}

test "parseDate" {
    try std.testing.expectEqual([3]u16{ 3025, 1, 1 }, try parseDate("3025-1-1"));
    try std.testing.expectEqual([3]u16{ 3026, 12, 31 }, try parseDate("3026-12-31"));
    try std.testing.expectError(error.BadDate, parseDate("3025-1"));
    try std.testing.expectError(error.BadDate, parseDate("3025-1-1-1"));
    try std.testing.expectError(error.InvalidCharacter, parseDate("3025-x-1"));
}
