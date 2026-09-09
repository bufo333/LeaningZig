//! Chapter 37, exercise 3: assert, unreachable, or error?
//! Run with:  zig test ex3_assert.zig
//! Goal: implement the three functions, choosing the right tool for each
//! impossible case: `std.debug.assert` for a caller-side contract,
//! `unreachable` for a case the type system already excludes, and an
//! error for input that comes from the outside world.
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

const Month = enum(u8) { jan = 1, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec };

/// Days in a month of a non-leap year.
pub fn daysInMonth(month: Month) u8 {
    // TODO: a switch. Does it need an else arm?
    _ = month;
    return 0;
}

/// The caller promises `bp` is at most 100 percent.
pub fn discount(amount: i64, bp: i64) i64 {
    // TODO: enforce the promise, then compute amount minus bp of amount
    _ = bp;
    return amount;
}

/// Text typed by a user.
pub fn parseMonth(text: []const u8) error{UnknownMonth}!Month {
    // TODO: std.meta.stringToEnum
    _ = text;
    return error.UnknownMonth;
}

/// A digit character 0-9 to its value. Callers filter with isDigit first.
pub fn digitValue(ch: u8) u8 {
    // TODO
    return ch;
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
