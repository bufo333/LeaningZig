//! Chapter 05, exercise 1: integer in, float out.
//! Run with:  zig test ex1_average.zig
//! Goal: make every test pass without changing the tests.
//! You will need @floatFromInt, @intFromFloat and @round.
const std = @import("std");

/// Average of three tonnages as an f64 (so 20, 55, 100 gives 58.333...).
fn average3(a: u32, b: u32, c: u32) f64 {
    _ = a;
    _ = b;
    _ = c;
    return 0; // TODO
}

/// Percentage of `part` out of `whole`, rounded to the nearest whole number.
/// 1 out of 3 is 33, 2 out of 3 is 67.
fn percent(part: u32, whole: u32) u32 {
    _ = part;
    _ = whole;
    return 0; // TODO
}

test "average3" {
    try std.testing.expectApproxEqAbs(@as(f64, 58.3333), average3(20, 55, 100), 0.001);
    try std.testing.expectEqual(@as(f64, 50), average3(50, 50, 50));
}

test "percent rounds" {
    try std.testing.expectEqual(@as(u32, 33), percent(1, 3));
    try std.testing.expectEqual(@as(u32, 67), percent(2, 3));
    try std.testing.expectEqual(@as(u32, 100), percent(7, 7));
    try std.testing.expectEqual(@as(u32, 0), percent(0, 7));
}
