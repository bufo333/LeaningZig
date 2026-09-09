//! Chapter 19, exercise 3: find and fix the leak.
//! Run with:  zig test ex3_leak.zig
//! Goal: make every test pass without changing the tests. In the
//! starter, one error path forgets to free; the testing allocator
//! reports it.
const std = @import("std");

/// Reads "name:skill" into a heap copy of the name and a number.
const Entry = struct { name: []u8, skill: u8 };

fn parseEntry(a: std.mem.Allocator, text: []const u8) !Entry {
    const colon = std.mem.indexOfScalar(u8, text, ':') orelse return error.NoColon;
    const name = try a.dupe(u8, text[0..colon]);
    // TODO: one line is missing here. Run the tests and read the leak report.
    const skill = try std.fmt.parseInt(u8, text[colon + 1 ..], 10);
    return .{ .name = name, .skill = skill };
}

test "good entry" {
    const a = std.testing.allocator;
    const e = try parseEntry(a, "Ada:4");
    defer a.free(e.name);
    try std.testing.expectEqualStrings("Ada", e.name);
    try std.testing.expectEqual(@as(u8, 4), e.skill);
}

test "bad entries leak nothing" {
    const a = std.testing.allocator;
    try std.testing.expectError(error.NoColon, parseEntry(a, "Ada"));
    try std.testing.expectError(error.InvalidCharacter, parseEntry(a, "Ada:four"));
}
