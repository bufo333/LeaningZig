//! Chapter 20, exercise 1: an arena for a pile of short-lived strings.
//! Run with:  zig test ex1_arena.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

/// Build a report of `n` lines using `a` and return the lines. The
/// caller decides how to free (with an arena: one deinit).
fn report(a: std.mem.Allocator, n: u32) ![][]const u8 {
    // TODO: implement
    @panic("TODO");
}

test "arena frees everything at once" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit(); // this is the ONLY free in the test
    const a = arena.allocator();

    const lines = try report(a, 50);
    try std.testing.expectEqual(@as(usize, 50), lines.len);
    try std.testing.expectEqualStrings("day 50: nothing to report", lines[49]);
}

test "the same function works with a plain allocator, if you free" {
    const a = std.testing.allocator;
    const lines = try report(a, 3);
    defer {
        for (lines) |l| a.free(l);
        a.free(lines);
    }
    try std.testing.expectEqualStrings("day 2: nothing to report", lines[1]);
}
