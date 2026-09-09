//! Chapter 15, exercise 3: write your own iterator.
//! Run with:  zig test ex3_iterator.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Yields `start`, `start + step`, ... while the value is below `end`.
const Range = struct {
    next_value: u32,
    end: u32,
    step: u32,

    fn init(start: u32, end: u32, step: u32) Range {
        return .{ .next_value = start, .end = end, .step = step };
    }

    /// Return the next value, or null once the range is exhausted.
    fn next(self: *Range) ?u32 {
        if (self.next_value >= self.end) return null;
        const v = self.next_value;
        self.next_value += self.step;
        return v;
    }
};

/// Drain an iterator with `while (it.next()) |v|` and add up the values.
fn sum(it: *Range) u32 {
    var total: u32 = 0;
    while (it.next()) |v| total += v;
    return total;
}

test "range yields then stops" {
    var r = Range.init(0, 10, 3);
    try std.testing.expectEqual(@as(?u32, 0), r.next());
    try std.testing.expectEqual(@as(?u32, 3), r.next());
    try std.testing.expectEqual(@as(?u32, 6), r.next());
    try std.testing.expectEqual(@as(?u32, 9), r.next());
    try std.testing.expectEqual(@as(?u32, null), r.next());
    try std.testing.expectEqual(@as(?u32, null), r.next());
}

test "sum drains it" {
    var r = Range.init(1, 5, 1);
    try std.testing.expectEqual(@as(u32, 10), sum(&r));
    var empty = Range.init(5, 5, 1);
    try std.testing.expectEqual(@as(u32, 0), sum(&empty));
}
