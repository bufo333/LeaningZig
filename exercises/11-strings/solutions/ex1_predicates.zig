//! Chapter 11, exercise 1: string predicates.
//! Run with:  zig test ex1_predicates.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// True when the command is one of the quit words, ignoring case and
/// surrounding whitespace.
fn isQuit(cmd: []const u8) bool {
    const t = std.mem.trim(u8, cmd, " \t\r\n");
    return std.ascii.eqlIgnoreCase(t, "quit") or std.ascii.eqlIgnoreCase(t, "q") or
        std.ascii.eqlIgnoreCase(t, "exit");
}

/// True when every byte is a decimal digit and there is at least one.
fn isNumber(s: []const u8) bool {
    if (s.len == 0) return false;
    for (s) |c| {
        if (!std.ascii.isDigit(c)) return false;
    }
    return true;
}

/// True when `s` looks like "hq:<digits>".
fn isHqRef(s: []const u8) bool {
    return std.mem.startsWith(u8, s, "hq:") and isNumber(s["hq:".len..]);
}

test "isQuit" {
    try std.testing.expect(isQuit("quit"));
    try std.testing.expect(isQuit("  Q\n"));
    try std.testing.expect(isQuit("EXIT"));
    try std.testing.expect(!isQuit("quit now"));
    try std.testing.expect(!isQuit(""));
}

test "isNumber" {
    try std.testing.expect(isNumber("3025"));
    try std.testing.expect(isNumber("0"));
    try std.testing.expect(!isNumber(""));
    try std.testing.expect(!isNumber("30x5"));
    try std.testing.expect(!isNumber("-1"));
}

test "isHqRef" {
    try std.testing.expect(isHqRef("hq:1"));
    try std.testing.expect(isHqRef("hq:42"));
    try std.testing.expect(!isHqRef("hq:"));
    try std.testing.expect(!isHqRef("co:1"));
    try std.testing.expect(!isHqRef("hq"));
}
