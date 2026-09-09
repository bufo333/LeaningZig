//! Chapter 08, exercise 4: write the tests yourself.
//! Run with:  zig test ex4_write_tests.zig
//! Goal: the functions are given. Write at least three tests for each, including
//! one edge case (zero, empty, negative). Finish with a refAllDecls test.
const std = @import("std");

pub fn absDiff(a: i32, b: i32) u32 {
    return if (a > b) @intCast(a - b) else @intCast(b - a);
}

pub fn isPalindrome(s: []const u8) bool {
    if (s.len < 2) return true;
    var i: usize = 0;
    var j: usize = s.len - 1;
    while (i < j) : ({
        i += 1;
        j -= 1;
    }) {
        if (s[i] != s[j]) return false;
    }
    return true;
}

test "absDiff: ordinary values" {
    try std.testing.expectEqual(@as(u32, 4), absDiff(7, 3));
    try std.testing.expectEqual(@as(u32, 4), absDiff(3, 7));
}

test "absDiff: negatives and zero" {
    try std.testing.expectEqual(@as(u32, 0), absDiff(5, 5));
    try std.testing.expectEqual(@as(u32, 10), absDiff(-5, 5));
    try std.testing.expectEqual(@as(u32, 2), absDiff(-7, -5));
}

test "isPalindrome: true cases" {
    try std.testing.expect(isPalindrome("racecar"));
    try std.testing.expect(isPalindrome("abba"));
    try std.testing.expect(isPalindrome("x"));
}

test "isPalindrome: empty string is a palindrome" {
    try std.testing.expect(isPalindrome(""));
}

test "isPalindrome: false cases" {
    try std.testing.expect(!isPalindrome("lance"));
    try std.testing.expect(!isPalindrome("ab"));
}

test {
    std.testing.refAllDecls(@This());
}
