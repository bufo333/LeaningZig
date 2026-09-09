//! Chapter 15, exercise 1: a lookup that may find nothing.
//! Run with:  zig test ex1_lookup.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const roster = [_][]const u8{ "Kerensky", "Steiner", "Liao", "Davion" };

/// Return the index of `name` in the roster, or null when it is not there.
fn find(name: []const u8) ?usize {
    for (roster, 0..) |entry, i| {
        if (std.mem.eql(u8, entry, name)) return i;
    }
    return null;
}

/// Return the name that follows `name`, or null when `name` is unknown
/// or already the last one. Use `orelse return null`.
fn after(name: []const u8) ?[]const u8 {
    const i = find(name) orelse return null;
    if (i + 1 >= roster.len) return null;
    return roster[i + 1];
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
