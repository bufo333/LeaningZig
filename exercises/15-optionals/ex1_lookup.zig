//! Chapter 15, exercise 1: a lookup that may find nothing.
//! Run with:  zig test ex1_lookup.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

const roster = [_][]const u8{ "Kerensky", "Steiner", "Liao", "Davion" };

/// Return the index of `name` in the roster, or null when it is not there.
fn find(name: []const u8) ?usize {
    // TODO: implement
    @panic("TODO");
}

/// Return the name that follows `name`, or null when `name` is unknown
/// or already the last one. Use `orelse return null`.
fn after(name: []const u8) ?[]const u8 {
    // TODO: implement
    @panic("TODO");
}

test "find present and absent" {
    try std.testing.expectEqual(@as(?usize, 1), find("Steiner"));
    try std.testing.expectEqual(@as(?usize, 3), find("Davion"));
    try std.testing.expectEqual(@as(?usize, null), find("Marik"));
}

test "after" {
    try std.testing.expectEqualStrings("Liao", after("Steiner").?);
    try std.testing.expect(after("Davion") == null);
    try std.testing.expect(after("Marik") == null);
}
