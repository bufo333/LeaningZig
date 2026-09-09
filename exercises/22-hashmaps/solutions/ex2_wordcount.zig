//! Chapter 22, exercise 2: count words.
//! Run with:  zig test ex2_wordcount.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Count = struct { word: []const u8, n: u32 };

/// Count each whitespace-separated word in `text`. The words are slices into `text`,
/// so the returned array is valid as long as `text` is.
/// Results are sorted by count descending, then word ascending.
fn wordCounts(gpa: std.mem.Allocator, text: []const u8) ![]Count {
    var map: std.StringHashMapUnmanaged(u32) = .empty;
    defer map.deinit(gpa);

    var it = std.mem.tokenizeAny(u8, text, " \t\n");
    while (it.next()) |w| {
        const gop = try map.getOrPut(gpa, w);
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }

    var out: std.ArrayList(Count) = .empty;
    errdefer out.deinit(gpa);
    var mit = map.iterator();
    while (mit.next()) |e| try out.append(gpa, .{ .word = e.key_ptr.*, .n = e.value_ptr.* });

    std.mem.sort(Count, out.items, {}, struct {
        fn lt(_: void, a: Count, b: Count) bool {
            if (a.n != b.n) return a.n > b.n;
            return std.mem.lessThan(u8, a.word, b.word);
        }
    }.lt);
    return out.toOwnedSlice(gpa);
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
