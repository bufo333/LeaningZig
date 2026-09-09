//! Chapter 06, exercise 2: switch on ranges and lists.
//! Run with:  zig test ex2_dice.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Outcome of a 2d6 roll: 2..4 "disaster", 5..8 "setback", 9..11 "success",
/// 12 "triumph". Anything else cannot happen with two dice.
fn outcome(roll: u8) []const u8 {
    return switch (roll) {
        2...4 => "disaster",
        5...8 => "setback",
        9...11 => "success",
        12 => "triumph",
        else => unreachable,
    };
}

/// Days in a month of the year 3025 (not a leap year).
fn daysInMonth(month: u8) u8 {
    return switch (month) {
        1, 3, 5, 7, 8, 10, 12 => 31,
        4, 6, 9, 11 => 30,
        2 => 28,
        else => 0,
    };
}

/// A single keypress in the terminal client: 'q' quits, 'h' or '?' shows
/// help, a digit selects that slot (0..9), anything else is ignored.
const Action = enum { quit, help, select, ignore };

fn keyAction(key: u8) Action {
    return switch (key) {
        'q' => .quit,
        'h', '?' => .help,
        '0'...'9' => .select,
        else => .ignore,
    };
}

test "outcome" {
    try std.testing.expectEqualStrings("disaster", outcome(2));
    try std.testing.expectEqualStrings("disaster", outcome(4));
    try std.testing.expectEqualStrings("setback", outcome(5));
    try std.testing.expectEqualStrings("success", outcome(11));
    try std.testing.expectEqualStrings("triumph", outcome(12));
}

test "daysInMonth" {
    try std.testing.expectEqual(@as(u8, 31), daysInMonth(1));
    try std.testing.expectEqual(@as(u8, 28), daysInMonth(2));
    try std.testing.expectEqual(@as(u8, 30), daysInMonth(4));
    try std.testing.expectEqual(@as(u8, 0), daysInMonth(13));
}

test "keyAction" {
    try std.testing.expectEqual(Action.quit, keyAction('q'));
    try std.testing.expectEqual(Action.help, keyAction('?'));
    try std.testing.expectEqual(Action.select, keyAction('7'));
    try std.testing.expectEqual(Action.ignore, keyAction('x'));
}
