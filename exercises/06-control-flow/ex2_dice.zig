//! Chapter 06, exercise 2: switch on ranges and lists.
//! Run with:  zig test ex2_dice.zig
//! Goal: make every test pass without changing the tests.
//! Each body is a TODO: write one switch expression per function. `Action`
//! is an enum; write its values as .quit, .help and so on (Chapter 13 explains).
const std = @import("std");

/// Outcome of a 2d6 roll: 2..4 "disaster", 5..8 "setback", 9..11 "success",
/// 12 "triumph". Anything else cannot happen with two dice.
fn outcome(roll: u8) []const u8 {
    _ = roll;
    return "TODO";
}

/// Days in a month of the year 3025 (not a leap year).
fn daysInMonth(month: u8) u8 {
    _ = month;
    return 0; // TODO
}

/// A single keypress in the terminal client: 'q' quits, 'h' or '?' shows
/// help, a digit selects that slot (0..9), anything else is ignored.
const Action = enum { quit, help, select, ignore };

fn keyAction(key: u8) Action {
    _ = key;
    return .ignore; // TODO
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
