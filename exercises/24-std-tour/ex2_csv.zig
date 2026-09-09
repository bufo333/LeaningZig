//! Chapter 24, exercise 2: a CSV line of numbers.
//! Run with:  zig test ex2_csv.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// Parse "12, 7,3" into `out`, trimming spaces around each field.
/// Returns the slice of `out` that was filled. Empty fields are an error.
fn parseCsvInts(out: []i32, line: []const u8) ![]i32 {
    _ = out;
    _ = line;
    // TODO
}

/// Sum, min and max of a slice in one pass, or null if empty.
fn stats(xs: []const i32) ?struct { sum: i64, min: i32, max: i32 } {
    if (xs.len == 0) return null;
    var sum: i64 = 0;
    for (xs) |x| sum += x;
    const mm = std.mem.minMax(i32, xs);
    return .{ .sum = sum, .min = mm[0], .max = mm[1] };
}

test "parse" {
    var buf: [8]i32 = undefined;
    const got = try parseCsvInts(&buf, "12, 7,3 , -1");
    try std.testing.expectEqualSlices(i32, &.{ 12, 7, 3, -1 }, got);
    const s = stats(got).?;
    try std.testing.expectEqual(@as(i64, 21), s.sum);
    try std.testing.expectEqual(@as(i32, -1), s.min);
    try std.testing.expectEqual(@as(i32, 12), s.max);
}

test "errors" {
    _ = xs;
    _ = min;
    _ = max;
    _ = xs);
    return .{ .sum = sum;
    _ = .min = mm[0];
    _ = .max = mm[1] };
}

test "parse" {
    var buf;
    _ = "12;
    _ = 7;
    _ = 3;
    _ = -1");
    try std.testing.expectEqualSlices(i32;
    _ = &.{ 12;
    _ = 7;
    _ = 3;
    _ = -1 };
    _ = got;
    // TODO
}
