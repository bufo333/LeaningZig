//! Chapter 11, exercise 4: bytes are not characters (challenge).
//! Run with:  zig test ex4_utf8.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// Number of code points, or error.Utf8InvalidStartByte for malformed input.
/// Hint: std.unicode.utf8CountCodepoints.
fn charCount(s: []const u8) !usize {
    _ = s;
    // TODO
}

/// The first `n` code points of `s` (fewer if s is shorter), as a slice of s.
/// Never cuts a multi-byte character in half.
/// Hint: std.unicode.Utf8View.init(s), then .iterator() and nextCodepointSlice();
/// the iterator's `i` field is the byte offset reached so far.
fn takeChars(s: []const u8, n: usize) ![]const u8 {
    _ = s;
    _ = n;
    // TODO
}

/// Reverse a string byte-by-byte into buf. Only valid for ASCII input,
/// so refuse anything with a byte >= 0x80 with error.NotAscii.
fn reverseAscii(buf: []u8, s: []const u8) ![]const u8 {
    _ = buf;
    _ = s;
    // TODO
}

test "charCount" {
    try std.testing.expectEqual(@as(usize, 3), try charCount("Mëk"));
    try std.testing.expectEqual(@as(usize, 4), "Mëk".len);
    try std.testing.expectEqual(@as(usize, 0), try charCount(""));
    try std.testing.expectError(error.Utf8InvalidStartByte, charCount("\xff"));
}

test "takeChars" {
    try std.testing.expectEqualStrings("Më", try takeChars("Mëk", 2));
    try std.testing.expectEqualStrings("Mëk", try takeChars("Mëk", 10));
    try std.testing.expectEqualStrings("", try takeChars("Mëk", 0));
}

test "reverseAscii" {
    var buf: [16]u8 = undefined;
    try std.testing.expectEqualStrings("salta", try reverseAscii(&buf, "atlas"));
    try std.testing.expectError(error.NotAscii, reverseAscii(&buf, "Mëk"));
}
