//! Chapter 15, exercise 2: defaults and first-present.
//! Run with:  zig test ex2_orelse.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// The tonnage of a unit, or 50 when the catalogue had no entry.
fn tonnageOr50(found: ?u8) u8 {
    return found orelse 50;
}

/// The first of three optionals that is present, or null if none is.
fn firstPresent(a: ?u32, b: ?u32, c: ?u32) ?u32 {
    return a orelse b orelse c;
}

/// Sum of the present values only. Use `if (x) |v|`.
fn sumPresent(values: []const ?u32) u32 {
    var total: u32 = 0;
    for (values) |maybe| {
        if (maybe) |v| total += v;
    }
    return total;
}

/// How many are null? Use `== null`.
fn countMissing(values: []const ?u32) usize {
    var n: usize = 0;
    for (values) |maybe| {
        if (maybe == null) n += 1;
    }
    return n;
}

test "tonnageOr50" {
    try std.testing.expectEqual(@as(u8, 75), tonnageOr50(75));
    try std.testing.expectEqual(@as(u8, 50), tonnageOr50(null));
}

test "firstPresent" {
    try std.testing.expectEqual(@as(?u32, 2), firstPresent(null, 2, 3));
    try std.testing.expectEqual(@as(?u32, 3), firstPresent(null, null, 3));
    try std.testing.expectEqual(@as(?u32, null), firstPresent(null, null, null));
}

test "sumPresent and countMissing" {
    const vals = [_]?u32{ 1, null, 4, null, 10 };
    try std.testing.expectEqual(@as(u32, 15), sumPresent(&vals));
    try std.testing.expectEqual(@as(usize, 2), countMissing(&vals));
}
