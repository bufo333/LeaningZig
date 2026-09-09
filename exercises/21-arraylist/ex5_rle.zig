//! Chapter 21, exercise 5: run-length encoding into a list of structs.
//! Run with:  zig test ex5_rle.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Run = struct { byte: u8, count: u32 };

/// "aaab" -> [{a,3},{b,1}]
fn encode(gpa: std.mem.Allocator, input: []const u8) ![]Run {
    _ = gpa; _ = input;
    // TODO: extend the last run if the byte matches, else append a new run.
}

/// The reverse. Look at appendNTimes.
fn decode(gpa: std.mem.Allocator, runs: []const Run) ![]u8 {
    _ = gpa; _ = runs;
    // TODO
}

test "encode" {
    const runs = try encode(std.testing.allocator, "aaabccdddd");
    defer std.testing.allocator.free(runs);
    try std.testing.expectEqual(@as(usize, 4), runs.len);
    try std.testing.expectEqual(Run{ .byte = 'a', .count = 3 }, runs[0]);
    try std.testing.expectEqual(Run{ .byte = 'd', .count = 4 }, runs[3]);
}

test "round trip" {
    const text = "mmmmeeeeccchhh warrior";
    const runs = try encode(std.testing.allocator, text);
    defer std.testing.allocator.free(runs);
    const back = try decode(std.testing.allocator, runs);
    defer std.testing.allocator.free(back);
    try std.testing.expectEqualStrings(text, back);
}

test "empty" {
    const runs = try encode(std.testing.allocator, "");
    defer std.testing.allocator.free(runs);
    try std.testing.expectEqual(@as(usize, 0), runs.len);
}
