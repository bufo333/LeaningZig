//! Chapter 14, exercise 2: decoding bytes into keys.
//! Run with:  zig test ex2_keys.zig
//! Goal: make every test pass without changing the tests.
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

/// Decode one raw byte the way src/tui/term.zig does.
fn decode(b: u8) Key {
    return switch (b) {
        0x1b => .escape,
        '\r', '\n' => .enter,
        '\t' => .tab,
        0x7f, 0x08 => .backspace,
        1...7, 11, 12, 14...26 => .{ .ctrl = 'a' + b - 1 },
        else => .{ .char = b },
    };
}

/// A short human name for a key, into buf.
fn describe(k: Key, buf: []u8) ![]const u8 {
    return switch (k) {
        .char => |c| std.fmt.bufPrint(buf, "'{u}'", .{c}),
        .ctrl => |c| std.fmt.bufPrint(buf, "ctrl-{c}", .{c}),
        .enter, .escape, .tab, .backspace, .none => @tagName(k),
    };
}

/// Count how many of the keys are printable characters.
fn countChars(keys: []const Key) usize {
    var n: usize = 0;
    for (keys) |k| {
        if (k == .char) n += 1;
    }
    return n;
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
