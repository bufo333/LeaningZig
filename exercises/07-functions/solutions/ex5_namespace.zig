//! Chapter 07, exercise 5: functions grouped in a struct namespace.
//! Run with:  zig test ex5_namespace.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Money helpers, grouped under one name. Chapter 12 covers structs fully;
/// here the struct has no fields and only holds functions.
const Money = struct {
    pub const bp_one: i64 = 10_000;

    /// Scale by basis points, rounding toward zero.
    pub fn applyBp(amount: i64, bp: i64) i64 {
        return @divTrunc(amount * bp, bp_one);
    }

    /// Ten percent markup.
    pub fn markup(amount: i64) i64 {
        return applyBp(amount, 11_000);
    }

    /// Split evenly between `shares` people; the remainder is lost.
    pub fn share(amount: i64, shares: i64) i64 {
        return @divTrunc(amount, shares);
    }
};

test "Money.applyBp" {
    try std.testing.expectEqual(@as(i64, 1_500), Money.applyBp(1_000, 15_000));
    try std.testing.expectEqual(@as(i64, -15), Money.applyBp(-100, 1_500));
}

test "Money.markup" {
    try std.testing.expectEqual(@as(i64, 1_100), Money.markup(1_000));
}

test "Money.share" {
    try std.testing.expectEqual(@as(i64, 333), Money.share(1_000, 3));
    try std.testing.expectEqual(@as(i64, 250), Money.share(1_000, 4));
}
