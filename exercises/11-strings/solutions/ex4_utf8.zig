//! Chapter 11, exercise 4: bytes are not characters (challenge).
//! Run with:  zig test ex4_utf8.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Number of code points, or error.Utf8InvalidStartByte for malformed input.
fn charCount(s: []const u8) !usize {
    return std.unicode.utf8CountCodepoints(s);
}

/// The first `n` code points of `s` (fewer if s is shorter), as a slice of s.
/// Never cuts a multi-byte character in half.
fn takeChars(s: []const u8, n: usize) ![]const u8 {
    var view = try std.unicode.Utf8View.init(s);
    var it = view.iterator();
    var taken: usize = 0;
    while (taken < n) : (taken += 1) {
        if (it.nextCodepointSlice() == null) break;
    }
    return s[0..it.i];
}

/// Reverse a string byte-by-byte into buf. Only valid for ASCII input,
/// so refuse anything with a byte >= 0x80.
fn reverseAscii(buf: []u8, s: []const u8) ![]const u8 {
    for (s) |c| {
        if (c >= 0x80) return error.NotAscii;
    }
    for (s, 0..) |c, i| buf[s.len - 1 - i] = c;
    return buf[0..s.len];
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
