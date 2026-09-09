//! Chapter 11, exercise 3: building strings into a buffer.
//! Run with:  zig test ex3_build.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// "Last, First" into buf.
fn fullName(buf: []u8, first: []const u8, last: []const u8) ![]const u8 {
    return std.fmt.bufPrint(buf, "{s}, {s}", .{ last, first });
}

/// The words of `line` joined by a single space, upper-cased, into buf.
fn shoutWords(buf: []u8, line: []const u8) ![]const u8 {
    var w = std.Io.Writer.fixed(buf);
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    var first = true;
    while (it.next()) |word| {
        if (!first) try w.writeByte(' ');
        first = false;
        for (word) |c| try w.writeByte(std.ascii.toUpper(c));
    }
    return w.buffered();
}

/// A C-bills amount with thousands separators: 1234567 -> "1,234,567".
fn money(buf: []u8, amount: u64) ![]const u8 {
    var digits: [20]u8 = undefined;
    const d = try std.fmt.bufPrint(&digits, "{d}", .{amount});
    var w = std.Io.Writer.fixed(buf);
    for (d, 0..) |c, i| {
        const remaining = d.len - i;
        if (i != 0 and remaining % 3 == 0) try w.writeByte(',');
        try w.writeByte(c);
    }
    return w.buffered();
}

test "fullName" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings("Allard, Kai", try fullName(&buf, "Kai", "Allard"));
}

test "fullName refuses a too-small buffer" {
    var buf: [4]u8 = undefined;
    try std.testing.expectError(error.NoSpaceLeft, fullName(&buf, "Kai", "Allard"));
}

test "shoutWords" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqualStrings("HIRE KAI NOW", try shoutWords(&buf, "  hire   kai now "));
    try std.testing.expectEqualStrings("", try shoutWords(&buf, ""));
}

test "money" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings("0", try money(&buf, 0));
    try std.testing.expectEqualStrings("999", try money(&buf, 999));
    try std.testing.expectEqualStrings("1,000", try money(&buf, 1000));
    try std.testing.expectEqualStrings("1,234,567", try money(&buf, 1234567));
}
