//! Chapter 07, exercise 3: functions as values.
//! Run with:  zig test ex3_fn_values.zig
//! Goal: make every test pass without changing the tests.
//! `?Op` means "an Op or null" (Chapter 15). Return a function name or null.
const std = @import("std");

const Op = *const fn (i64, i64) i64;

fn add(a: i64, b: i64) i64 {
    return a + b;
}

fn mul(a: i64, b: i64) i64 {
    return a * b;
}

fn maxOf(a: i64, b: i64) i64 {
    return @max(a, b);
}

/// Fold `items` with `op`, starting from `start`: op(op(op(start, a), b), c).
fn fold(items: []const i64, start: i64, op: Op) i64 {
    _ = items;
    _ = op;
    return start; // TODO
}

/// Pick the operation for a one-character symbol: '+' add, '*' mul, 'M' maxOf.
fn opFor(symbol: u8) ?Op {
    _ = symbol;
    return null; // TODO
}

test "fold" {
    const xs = [_]i64{ 2, 3, 4 };
    try std.testing.expectEqual(@as(i64, 9), fold(&xs, 0, add));
    try std.testing.expectEqual(@as(i64, 24), fold(&xs, 1, mul));
    try std.testing.expectEqual(@as(i64, 4), fold(&xs, -100, maxOf));
    try std.testing.expectEqual(@as(i64, 5), fold(&.{}, 5, add));
}

test "opFor" {
    const xs = [_]i64{ 10, 20 };
    const plus = opFor('+') orelse return error.NoOp;
    try std.testing.expectEqual(@as(i64, 30), fold(&xs, 0, plus));
    const times = opFor('*') orelse return error.NoOp;
    try std.testing.expectEqual(@as(i64, 200), fold(&xs, 1, times));
    try std.testing.expect(opFor('?') == null);
}
