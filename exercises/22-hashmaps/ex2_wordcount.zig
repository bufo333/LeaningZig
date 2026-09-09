//! Chapter 22, exercise 2: count words.
//! Run with:  zig test ex2_wordcount.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Count = struct { word: []const u8, n: u32 };

/// Count each whitespace-separated word in `text`. The words are slices into `text`,
/// so the returned array is valid as long as `text` is.
/// Results are sorted by count descending, then word ascending.
fn wordCounts(gpa: std.mem.Allocator, text: []const u8) ![]Count {
    _ = gpa;
    _ = text;
    // TODO
}

test "counts" {
    const text = "the mech the pilot the lance\nmech pilot";
    const counts = try wordCounts(std.testing.allocator, text);
    defer std.testing.allocator.free(counts);
    try std.testing.expectEqual(@as(usize, 4), counts.len);
    try std.testing.expectEqualStrings("the", counts[0].word);
    try std.testing.expectEqual(@as(u32, 3), counts[0].n);
    try std.testing.expectEqualStrings("mech", counts[1].word);
    try std.testing.expectEqualStrings("pilot", counts[2].word);
    try std.testing.expectEqualStrings("lance", counts[3].word);
}

test "empty text" {
    const counts = try wordCounts(std.testing.allocator, "   \n ");
    defer std.testing.allocator.free(counts);
    try std.testing.expectEqual(@as(usize, 0), counts.len);
}
