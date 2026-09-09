//! Chapter 04, exercise 3: basis points and signed division.
//! Run with:  zig test ex3_division.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const CBills = i64;
const Bp = i64;

/// Scale `amount` by `bp` basis points (10_000 = x1), rounding toward zero.
fn applyBp(amount: CBills, bp: Bp) CBills {
    return @divTrunc(amount * bp, 10_000);
}

/// Which week (starting at 0) a day index falls in, for negative days too.
/// Day -1 is the last day of week -1, not week 0.
fn weekOf(day: i32) i32 {
    return @divFloor(day, 7);
}

/// Day of the week, 0..6, for negative days too.
fn dayOfWeek(day: i32) i32 {
    return @mod(day, 7);
}

test "applyBp" {
    try std.testing.expectEqual(@as(CBills, 1_100), applyBp(1_000, 11_000));
    try std.testing.expectEqual(@as(CBills, 500), applyBp(1_000, 5_000));
    try std.testing.expectEqual(@as(CBills, -33), applyBp(-100, 3_333));
    try std.testing.expectEqual(@as(CBills, 33), applyBp(100, 3_333));
}

test "weekOf" {
    try std.testing.expectEqual(@as(i32, 0), weekOf(6));
    try std.testing.expectEqual(@as(i32, 1), weekOf(7));
    try std.testing.expectEqual(@as(i32, -1), weekOf(-1));
    try std.testing.expectEqual(@as(i32, -1), weekOf(-7));
    try std.testing.expectEqual(@as(i32, -2), weekOf(-8));
}

test "dayOfWeek" {
    try std.testing.expectEqual(@as(i32, 6), dayOfWeek(6));
    try std.testing.expectEqual(@as(i32, 0), dayOfWeek(7));
    try std.testing.expectEqual(@as(i32, 6), dayOfWeek(-1));
    try std.testing.expectEqual(@as(i32, 0), dayOfWeek(-7));
}
