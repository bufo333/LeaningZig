//! Chapter 24, exercise 2: a CSV line of numbers.
//! Run with:  zig test ex2_csv.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Parse "12, 7,3" into `out`, trimming spaces around each field.
/// Returns the slice of `out` that was filled. Empty fields are an error.
fn parseCsvInts(out: []i32, line: []const u8) ![]i32 {
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, line, ',');
    while (it.next()) |raw| {
        const field = std.mem.trim(u8, raw, " \t");
        if (field.len == 0) return error.EmptyField;
        if (n == out.len) return error.TooManyFields;
        out[n] = try std.fmt.parseInt(i32, field, 10);
        n += 1;
    }
    return out[0..n];
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
    var buf: [2]i32 = undefined;
    try std.testing.expectError(error.EmptyField, parseCsvInts(&buf, "1,,2"));
    try std.testing.expectError(error.TooManyFields, parseCsvInts(&buf, "1,2,3"));
    try std.testing.expectError(error.InvalidCharacter, parseCsvInts(&buf, "1,x"));
    try std.testing.expect(stats(&.{}) == null);
}
