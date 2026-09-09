//! Chapter 21, exercise 3: a string builder.
//! Run with:  zig test ex3_join.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// Join `parts` with `sep` between them. The caller owns the result.
fn joinWith(gpa: std.mem.Allocator, parts: []const []const u8, sep: []const u8) ![]u8 {
    _ = gpa;
    _ = parts;
    _ = sep;
    // TODO: ArrayList(u8), appendSlice, toOwnedSlice.
}

/// "3 units: Atlas, Locust, Marauder"  (and "1 unit: Atlas" for one)
fn describeLance(gpa: std.mem.Allocator, names: []const []const u8) ![]u8 {
    _ = gpa;
    _ = names;
    // TODO: use the list's print method for the count, then joinWith.
}

test "join three" {
    const s = try joinWith(std.testing.allocator, &.{ "a", "b", "c" }, ", ");
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings("a, b, c", s);
}

test "join one and none" {
    const one = try joinWith(std.testing.allocator, &.{"solo"}, "-");
    defer std.testing.allocator.free(one);
    try std.testing.expectEqualStrings("solo", one);
    const none = try joinWith(std.testing.allocator, &.{}, "-");
    defer std.testing.allocator.free(none);
    try std.testing.expectEqualStrings("", none);
}

test "describe" {
    const s = try describeLance(std.testing.allocator, &.{ "Atlas", "Locust" });
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings("2 units: Atlas, Locust", s);
    const t = try describeLance(std.testing.allocator, &.{"Atlas"});
    defer std.testing.allocator.free(t);
    try std.testing.expectEqualStrings("1 unit: Atlas", t);
}
