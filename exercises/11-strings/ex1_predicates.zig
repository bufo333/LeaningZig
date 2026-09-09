//! Chapter 11, exercise 1: string predicates.
//! Run with:  zig test ex1_predicates.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// True when the command is one of "quit", "q" or "exit", ignoring case and
/// surrounding whitespace. Hint: std.mem.trim, std.ascii.eqlIgnoreCase.
fn isQuit(cmd: []const u8) bool {
    _ = cmd;
    // TODO
}

/// True when every byte is a decimal digit and there is at least one.
fn isNumber(s: []const u8) bool {
    _ = s;
    // TODO
}

/// True when `s` looks like "hq:<digits>".
fn isHqRef(s: []const u8) bool {
    _ = s;
    // TODO: startsWith, then isNumber on the rest
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
