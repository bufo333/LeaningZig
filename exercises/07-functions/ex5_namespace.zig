//! Chapter 07, exercise 5: functions grouped in a struct namespace.
//! Run with:  zig test ex5_namespace.zig
//! Goal: make every test pass without changing the tests.
//! Add the three functions inside Money so the tests can call them as
//! Money.applyBp, Money.markup and Money.share. markup should call applyBp.
const std = @import("std");

/// Money helpers, grouped under one name. Chapter 12 covers structs fully;
/// here the struct has no fields and only holds functions.
const Money = struct {
    pub const bp_one: i64 = 10_000;

    // TODO: applyBp(amount, bp) scales by basis points, rounding toward zero.
    // TODO: markup(amount) is a ten percent markup (call applyBp).
    // TODO: share(amount, shares) splits evenly; the remainder is lost.
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
