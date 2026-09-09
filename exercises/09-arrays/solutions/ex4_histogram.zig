//! Chapter 09, exercise 4: a dice histogram (challenge).
//! Run with:  zig test ex4_histogram.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Given a list of 2d6 results (each 2..12), count how many times each total
/// appeared. Index 0 and 1 of the result are always zero.
fn histogram(rolls: []const u8) [13]u32 {
    var counts = [_]u32{0} ** 13;
    for (rolls) |r| {
        counts[r] += 1;
    }
    return counts;
}

/// The most frequent total. Ties go to the smaller total.
fn mode(counts: [13]u32) u8 {
    var best: u8 = 2;
    for (counts, 0..) |c, i| {
        if (c > counts[best]) best = @intCast(i);
    }
    return best;
}

/// Build a one-line text bar for a total: "7: ####" style, into buf.
fn bar(buf: []u8, total: u8, n: u32) []const u8 {
    const prefix = std.fmt.bufPrint(buf, "{d:>2}: ", .{total}) catch unreachable;
    var i: usize = 0;
    while (i < n) : (i += 1) buf[prefix.len + i] = '#';
    return buf[0 .. prefix.len + n];
}

test "histogram counts every total" {
    const h = histogram(&[_]u8{ 7, 7, 2, 12, 7, 6 });
    try std.testing.expectEqual(@as(u32, 3), h[7]);
    try std.testing.expectEqual(@as(u32, 1), h[2]);
    try std.testing.expectEqual(@as(u32, 1), h[12]);
    try std.testing.expectEqual(@as(u32, 0), h[3]);
    try std.testing.expectEqual(@as(u32, 0), h[0]);
}

test "empty input gives all zeros" {
    const h = histogram(&[_]u8{});
    try std.testing.expectEqual([_]u32{0} ** 13, h);
}

test "mode" {
    try std.testing.expectEqual(@as(u8, 7), mode(histogram(&[_]u8{ 7, 7, 2, 12, 7, 6 })));
    try std.testing.expectEqual(@as(u8, 3), mode(histogram(&[_]u8{ 9, 3, 3, 9 })));
}

test "bar" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings(" 7: ###", bar(&buf, 7, 3));
    try std.testing.expectEqualStrings("12: ", bar(&buf, 12, 0));
}
