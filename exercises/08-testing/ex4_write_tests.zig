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

// TODO: tests for absDiff

// TODO: tests for isPalindrome

// TODO: a refAllDecls test
