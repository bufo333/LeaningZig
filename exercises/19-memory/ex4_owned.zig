//! Chapter 19, exercise 4: an owned list of borrowed slices.
//! Run with:  zig test ex4_owned.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

/// Split `text` on newlines. The outer slice is OWNED by the caller
/// (free it with `a`); each inner slice BORROWS from `text`, so there
/// is nothing else to free. Empty lines are skipped.
fn lines(a: std.mem.Allocator, text: []const u8) ![][]const u8 {
    // TODO: implement
    @panic("TODO");
}

/// Total length of all lines. Borrows everything, allocates nothing.
fn totalLen(ls: []const []const u8) usize {
    // TODO: implement
    @panic("TODO");
}

test "lines" {
    const a = std.testing.allocator;
    const text = "hire Ada\n\nadvance 3\nquit\n";
    const ls = try lines(a, text);
    defer a.free(ls);
    try std.testing.expectEqual(@as(usize, 3), ls.len);
    try std.testing.expectEqualStrings("advance 3", ls[1]);
    try std.testing.expectEqual(@as(usize, 21), totalLen(ls));
    // borrowed: the line points into `text`
    try std.testing.expect(ls[0].ptr == text.ptr);
}

test "empty text" {
    const a = std.testing.allocator;
    const ls = try lines(a, "");
    defer a.free(ls);
    try std.testing.expectEqual(@as(usize, 0), ls.len);
}
