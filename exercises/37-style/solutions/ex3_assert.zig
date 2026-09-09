//! Chapter 37, exercise 3: assert, unreachable, or error?
//! Run with:  zig test ex3_assert.zig
//! Goal: implement the three functions, choosing the right tool for each
//! impossible case: `std.debug.assert` for a caller-side contract,
//! `unreachable` for a case the type system already excludes, and an
//! error for input that comes from the outside world.

const std = @import("std");

const Month = enum(u8) { jan = 1, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec };

/// Days in a month of a non-leap year. `month` is an enum, so every case
/// is covered: no `else` and no `unreachable` needed at all.
pub fn daysInMonth(month: Month) u8 {
    return switch (month) {
        .jan, .mar, .may, .jul, .aug, .oct, .dec => 31,
        .apr, .jun, .sep, .nov => 30,
        .feb => 28,
    };
}

/// The caller promises `bp` is at most 100 percent. Breaking that promise
/// is a bug in the caller, so we assert rather than return an error.
pub fn discount(amount: i64, bp: i64) i64 {
    std.debug.assert(bp >= 0 and bp <= 10_000);
    return amount - @divTrunc(amount * bp, 10_000);
}

/// Text typed by a user is not a bug when it is wrong; it is an error.
pub fn parseMonth(text: []const u8) error{UnknownMonth}!Month {
    return std.meta.stringToEnum(Month, text) orelse error.UnknownMonth;
}

/// A digit character 0-9 to its value. Callers filter with isDigit
/// first, so anything else is unreachable.
pub fn digitValue(ch: u8) u8 {
    return switch (ch) {
        '0'...'9' => ch - '0',
        else => unreachable,
    };
}

test "days in month" {
    try std.testing.expectEqual(@as(u8, 31), daysInMonth(.jan));
    try std.testing.expectEqual(@as(u8, 28), daysInMonth(.feb));
}

test "discount within contract" {
    try std.testing.expectEqual(@as(i64, 900), discount(1000, 1_000));
    try std.testing.expectEqual(@as(i64, 0), discount(1000, 10_000));
}

test "parseMonth reports bad input as an error" {
    try std.testing.expectEqual(Month.sep, try parseMonth("sep"));
    try std.testing.expectError(error.UnknownMonth, parseMonth("Sept"));
}

test "digitValue" {
    try std.testing.expectEqual(@as(u8, 7), digitValue('7'));
}
