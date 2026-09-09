//! Chapter 23, exercise 5: money with thousands separators, like IRON LEDGER's.
//! Run with:  zig test ex5_money.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// -1234567 -> "-1,234,567". The caller owns the result.
fn money(gpa: std.mem.Allocator, v: i64) ![]u8 {
    var digits: [24]u8 = undefined;
    const raw = try std.fmt.bufPrint(&digits, "{d}", .{@abs(v)});
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(gpa);
    if (v < 0) try out.append(gpa, '-');
    for (raw, 0..) |c, i| {
        if (i > 0 and (raw.len - i) % 3 == 0) try out.append(gpa, ',');
        try out.append(gpa, c);
    }
    return out.toOwnedSlice(gpa);
}

/// "1,234,567" or "-1,234,567" -> i64. Commas are optional; anything else is an error.
fn parseMoney(text: []const u8) !i64 {
    var clean: [32]u8 = undefined;
    var n: usize = 0;
    for (text) |c| {
        if (c == ',') continue;
        if (n == clean.len) return error.Overflow;
        clean[n] = c;
        n += 1;
    }
    return std.fmt.parseInt(i64, clean[0..n], 10);
}

fn check(expected: []const u8, v: i64) !void {
    const s = try money(std.testing.allocator, v);
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings(expected, s);
    try std.testing.expectEqual(v, try parseMoney(s));
}

test "money" {
    try check("0", 0);
    try check("999", 999);
    try check("1,000", 1000);
    try check("1,234,567", 1234567);
    try check("-950", -950);
    try check("-1,234,567", -1234567);
}

test "parse rejects junk" {
    try std.testing.expectError(error.InvalidCharacter, parseMoney("1,2x3"));
    try std.testing.expectEqual(@as(i64, 5000), try parseMoney("5000"));
}
