//! Chapter 05, exercise 2: comparing floats honestly.
//! Run with:  zig test ex2_approx.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// True when a and b are within `tolerance` of each other.
fn nearlyEqual(a: f64, b: f64, tolerance: f64) bool {
    return @abs(a - b) <= tolerance;
}

/// True when x is a finite number (not NaN, not +/- infinity).
fn isUsable(x: f64) bool {
    return !std.math.isNan(x) and !std.math.isInf(x);
}

test "nearlyEqual" {
    var sum: f64 = 0.0;
    for (0..10) |_| sum += 0.1;
    try std.testing.expect(sum != 1.0); // the classic surprise
    try std.testing.expect(nearlyEqual(sum, 1.0, 1e-9));
    try std.testing.expect(!nearlyEqual(1.0, 1.1, 0.01));
}

test "isUsable" {
    try std.testing.expect(isUsable(3.5));
    try std.testing.expect(isUsable(0.0));
    try std.testing.expect(!isUsable(std.math.nan(f64)));
    try std.testing.expect(!isUsable(std.math.inf(f64)));
    try std.testing.expect(!isUsable(-std.math.inf(f64)));
}
