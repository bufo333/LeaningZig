//! Chapter 07, exercise 2: recursion.
//! Run with:  zig test ex2_recursion.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Greatest common divisor by Euclid's algorithm: gcd(a, 0) = a,
/// otherwise gcd(b, a mod b).
fn gcd(a: u64, b: u64) u64 {
    if (b == 0) return a;
    return gcd(b, a % b);
}

/// base to the power exp, by repeated squaring:
/// pow(b, 0) = 1; even exp: pow(b*b, exp/2); odd exp: b * pow(b, exp-1).
fn pow(base: u64, exp: u32) u64 {
    if (exp == 0) return 1;
    if (exp % 2 == 0) return pow(base * base, exp / 2);
    return base * pow(base, exp - 1);
}

/// Number of decimal digits in n (0 has one digit).
fn digitCount(n: u64) u32 {
    if (n < 10) return 1;
    return 1 + digitCount(n / 10);
}

test "gcd" {
    try std.testing.expectEqual(@as(u64, 6), gcd(48, 18));
    try std.testing.expectEqual(@as(u64, 1), gcd(17, 5));
    try std.testing.expectEqual(@as(u64, 12), gcd(12, 0));
}

test "pow" {
    try std.testing.expectEqual(@as(u64, 1), pow(7, 0));
    try std.testing.expectEqual(@as(u64, 1024), pow(2, 10));
    try std.testing.expectEqual(@as(u64, 243), pow(3, 5));
}

test "digitCount" {
    try std.testing.expectEqual(@as(u32, 1), digitCount(0));
    try std.testing.expectEqual(@as(u32, 1), digitCount(9));
    try std.testing.expectEqual(@as(u32, 7), digitCount(9_626_000));
}
