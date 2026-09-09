//! Chapter 14, exercise 2: decoding bytes into keys.
//! Run with:  zig test ex2_keys.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// IRON LEDGER's terminal key type, trimmed.
const Key = union(enum) {
    char: u21,
    enter,
    escape,
    tab,
    backspace,
    ctrl: u8, // 'a'..'z'
    none,
};

/// Decode one raw byte the way src/tui/term.zig does:
/// 0x1b -> escape; '\r' or '\n' -> enter; '\t' -> tab; 0x7f or 0x08 -> backspace;
/// 1..7, 11, 12, 14..26 -> ctrl + letter ('a' + b - 1); anything else -> char.
fn decode(b: u8) Key {
    _ = b;
    // TODO: a switch on the byte with ranges and lists
}

/// A short human name for a key, into buf: "'q'", "ctrl-c", or the tag name.
fn describe(k: Key, buf: []u8) ![]const u8 {
    _ = k;
    _ = buf;
    // TODO
}

/// Count how many of the keys are printable characters.
fn countChars(keys: []const Key) usize {
    _ = keys;
    // TODO: compare the tag with k == .char
}

test "decode" {
    try std.testing.expectEqual(Key.escape, decode(0x1b));
    try std.testing.expectEqual(Key.enter, decode('\n'));
    try std.testing.expectEqual(Key.backspace, decode(0x7f));
    try std.testing.expectEqual(Key{ .ctrl = 'c' }, decode(3));
    try std.testing.expectEqual(Key{ .ctrl = 'z' }, decode(26));
    try std.testing.expectEqual(Key{ .char = 'q' }, decode('q'));
}

test "describe" {
    var buf: [16]u8 = undefined;
    try std.testing.expectEqualStrings("'q'", try describe(.{ .char = 'q' }, &buf));
    try std.testing.expectEqualStrings("ctrl-c", try describe(.{ .ctrl = 'c' }, &buf));
    try std.testing.expectEqualStrings("escape", try describe(.escape, &buf));
}

test "countChars" {
    const keys = [_]Key{ .{ .char = 'a' }, .enter, .{ .char = 'b' }, .{ .ctrl = 'c' }, .none };
    try std.testing.expectEqual(@as(usize, 2), countChars(&keys));
}
