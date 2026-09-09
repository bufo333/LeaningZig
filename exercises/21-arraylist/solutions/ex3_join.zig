//! Chapter 21, exercise 3: a string builder.
//! Run with:  zig test ex3_join.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Join `parts` with `sep` between them. The caller owns the result.
fn joinWith(gpa: std.mem.Allocator, parts: []const []const u8, sep: []const u8) ![]u8 {
    var sb: std.ArrayList(u8) = .empty;
    errdefer sb.deinit(gpa);
    for (parts, 0..) |p, i| {
        if (i > 0) try sb.appendSlice(gpa, sep);
        try sb.appendSlice(gpa, p);
    }
    return sb.toOwnedSlice(gpa);
}

/// "3 units: Atlas, Locust, Marauder"
fn describeLance(gpa: std.mem.Allocator, names: []const []const u8) ![]u8 {
    var sb: std.ArrayList(u8) = .empty;
    errdefer sb.deinit(gpa);
    try sb.print(gpa, "{d} unit{s}: ", .{ names.len, if (names.len == 1) "" else "s" });
    const joined = try joinWith(gpa, names, ", ");
    defer gpa.free(joined);
    try sb.appendSlice(gpa, joined);
    return sb.toOwnedSlice(gpa);
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
