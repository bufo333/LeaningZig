//! Chapter 06, exercise 3: loops that produce values, and labeled loops.
//! Run with:  zig test ex3_search.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Index of the first element equal to `wanted`, or null if absent.
/// Use a `for ... else` expression, not a separate flag variable.
fn indexOf(items: []const u32, wanted: u32) ?usize {
    return for (items, 0..) |item, i| {
        if (item == wanted) break i;
    } else null;
}

/// True when every row of the grid contains at least one zero.
/// Use a labeled outer loop with `continue :label`.
fn everyRowHasZero(grid: []const [3]u8) bool {
    var rows_with_zero: usize = 0;
    rows: for (grid) |row| {
        for (row) |cell| {
            if (cell == 0) {
                rows_with_zero += 1;
                continue :rows;
            }
        }
    }
    return rows_with_zero == grid.len;
}

/// Smallest divisor of n greater than 1 (n itself when n is prime).
/// Use a `while ... else` expression with a continue expression.
fn smallestDivisor(n: u32) u32 {
    var d: u32 = 2;
    return while (d * d <= n) : (d += 1) {
        if (n % d == 0) break d;
    } else n;
}

test "indexOf" {
    const roster = [_]u32{ 3, 8, 12, 27 };
    try std.testing.expectEqual(@as(?usize, 2), indexOf(&roster, 12));
    try std.testing.expectEqual(@as(?usize, 0), indexOf(&roster, 3));
    try std.testing.expectEqual(@as(?usize, null), indexOf(&roster, 99));
}

test "everyRowHasZero" {
    const yes = [_][3]u8{ .{ 1, 0, 2 }, .{ 0, 5, 5 }, .{ 7, 7, 0 } };
    const no = [_][3]u8{ .{ 1, 0, 2 }, .{ 4, 5, 5 } };
    try std.testing.expect(everyRowHasZero(&yes));
    try std.testing.expect(!everyRowHasZero(&no));
}

test "smallestDivisor" {
    try std.testing.expectEqual(@as(u32, 7), smallestDivisor(91));
    try std.testing.expectEqual(@as(u32, 2), smallestDivisor(100));
    try std.testing.expectEqual(@as(u32, 13), smallestDivisor(13));
}
