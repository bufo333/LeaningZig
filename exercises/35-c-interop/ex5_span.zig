//! Chapter 35, exercise 5: sentinel strings both ways.
//! Run with:  zig test ex5_span.zig
//! Goal: implement `toC` (copy a Zig slice into a sentinel-terminated
//! buffer for C) and `fromC` (turn a C string back into a slice) and
//! export a C-callable `ledger_bp` function. No libc needed.
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

/// Copy `s` into `buf` and add the terminating zero. Returns the
/// sentinel-terminated slice, or error.TooLong if it does not fit.
pub fn toC(buf: []u8, s: []const u8) error{TooLong}![:0]u8 {
    // TODO
    _ = buf;
    _ = s;
    return error.TooLong;
}

/// A C string comes back as a many-item pointer; find its length.
pub fn fromC(p: [*:0]const u8) []const u8 {
    // TODO: std.mem.span
    _ = p;
    return "";
}

/// Exported so a C caller could use it: apply basis points to an amount.
export fn ledger_bp(amount: i64, bp: i64) i64 {
    // TODO
    _ = amount;
    _ = bp;
    return 0;
}

test "toC adds the sentinel" {
    var buf: [16]u8 = undefined;
    const s = try toC(&buf, "Clay");
    try std.testing.expectEqual(@as(usize, 4), s.len);
    try std.testing.expectEqual(@as(u8, 0), s[4]);
    try std.testing.expectEqualStrings("Clay", s);
}

test "toC refuses when there is no room for the zero" {
    var buf: [4]u8 = undefined;
    try std.testing.expectError(error.TooLong, toC(&buf, "Clay"));
}

test "fromC finds the length" {
    const p: [*:0]const u8 = "Kalmar";
    try std.testing.expectEqualStrings("Kalmar", fromC(p));
    try std.testing.expectEqual(@as(usize, 6), fromC(p).len);
}

test "exported function is callable from Zig too" {
    try std.testing.expectEqual(@as(i64, 1650), ledger_bp(1500, 11_000));
}
