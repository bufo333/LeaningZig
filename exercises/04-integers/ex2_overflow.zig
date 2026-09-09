//! Chapter 04, exercise 2: overflow arithmetic.
//! Run with:  zig test ex2_overflow.zig
//! Goal: make every test pass without changing the tests.
//! As written, the tests panic with "integer overflow". Replace each plain
//! operator with the wrapping (%) or saturating (|) form the comment asks for.
const std = @import("std");

/// Add `heal` armor points but never exceed 255.
fn repair(armor: u8, heal: u8) u8 {
    return armor + heal; // TODO
}

/// Take `hit` points of damage but never go below zero.
fn damage(armor: u8, hit: u8) u8 {
    return armor - hit; // TODO
}

/// An 8-bit counter that is meant to roll over from 255 back to 0.
fn tick(counter: u8) u8 {
    return counter + 1; // TODO
}

/// Mix a seed the way a hash would: the multiplication is meant to overflow.
fn mix(seed: u64, i: u64) u64 {
    return seed ^ (0x9E3779B97F4A7C15 * (i + 1)); // TODO
}

test "repair saturates at 255" {
    try std.testing.expectEqual(@as(u8, 255), repair(250, 10));
    try std.testing.expectEqual(@as(u8, 60), repair(50, 10));
}

test "damage saturates at 0" {
    try std.testing.expectEqual(@as(u8, 0), damage(3, 5));
    try std.testing.expectEqual(@as(u8, 40), damage(50, 10));
}

test "tick wraps" {
    try std.testing.expectEqual(@as(u8, 0), tick(255));
    try std.testing.expectEqual(@as(u8, 8), tick(7));
}

test "mix does not panic and differs per index" {
    const a = mix(3025, 0);
    const b = mix(3025, 1_000_000_000);
    try std.testing.expect(a != b);
}
