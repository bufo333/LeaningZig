//! Chapter 25, exercise 4: strings built by the compiler.
//! Run with:  zig test ex4_labels.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// "weight (tons)" from ("weight", "tons"); "weight" alone when unit is empty.
/// An empty name is a compile error.
fn label(comptime name: []const u8, comptime unit: []const u8) []const u8 {
    // TODO
}

/// A column header: the label left-aligned and padded with spaces to `width`,
/// all decided at compile time.
fn header(comptime text: []const u8, comptime width: usize) []const u8 {
    // TODO
}

/// "v0.16.0" from three numbers.
fn version(comptime major: u32, comptime minor: u32, comptime patch: u32) []const u8 {
    // TODO
}

test "label" {
    try std.testing.expectEqualStrings("weight (tons)", label("weight", "tons"));
    try std.testing.expectEqualStrings("name", label("name", ""));
}

test "header" {
    try std.testing.expectEqualStrings("tons      ", header("tons", 10));
    try std.testing.expectEqualStrings("battle value", header("battle value", 5));
    try std.testing.expectEqual(@as(usize, 10), header("tons", 10).len);
}

test "version" {
    try std.testing.expectEqualStrings("v0.16.0", version(0, 16, 0));
    // The result is a compile-time constant, so it can size an array.
    const n = comptime version(1, 2, 3).len;
    const arr: [n]u8 = @splat('x');
    try std.testing.expectEqual(@as(usize, 6), arr.len);
}
