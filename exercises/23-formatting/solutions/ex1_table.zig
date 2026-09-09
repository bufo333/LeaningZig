//! Chapter 23, exercise 1: fixed-width table rows.
//! Run with:  zig test ex1_table.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// name left-aligned in 10, tons right-aligned in 5, bv right-aligned in 6, single spaces between.
fn formatRow(buf: []u8, name: []const u8, tons: u32, bv: u32) ![]u8 {
    return std.fmt.bufPrint(buf, "{s: <10} {d: >5} {d: >6}", .{ name, tons, bv });
}

/// "07:05" style, zero padded.
fn formatClock(buf: []u8, hours: u8, minutes: u8) ![]u8 {
    return std.fmt.bufPrint(buf, "{d:0>2}:{d:0>2}", .{ hours, minutes });
}

test "row" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqualStrings("Atlas        100   1897", try formatRow(&buf, "Atlas", 100, 1897));
    try std.testing.expectEqualStrings("Locust        20    432", try formatRow(&buf, "Locust", 20, 432));
}

test "clock" {
    var buf: [8]u8 = undefined;
    try std.testing.expectEqualStrings("07:05", try formatClock(&buf, 7, 5));
    try std.testing.expectEqualStrings("23:59", try formatClock(&buf, 23, 59));
}

test "a buffer that is too small is an error, not a truncation" {
    var tiny: [4]u8 = undefined;
    try std.testing.expectError(error.NoSpaceLeft, formatClock(&tiny, 7, 5));
}
