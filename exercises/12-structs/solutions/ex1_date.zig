//! Chapter 12, exercise 1: a Date struct with methods.
//! Run with:  zig test ex1_date.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Date = struct {
    year: u16,
    month: u8, // 1..12
    day: u8, // 1..31

    pub const campaign_default: Date = .{ .year = 3025, .month = 1, .day = 1 };

    pub fn isLeapYear(year: u16) bool {
        return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0;
    }

    pub fn daysInMonth(year: u16, month: u8) u8 {
        return switch (month) {
            1, 3, 5, 7, 8, 10, 12 => 31,
            4, 6, 9, 11 => 30,
            2 => if (isLeapYear(year)) @as(u8, 29) else 28,
            else => unreachable,
        };
    }

    /// The day after self, as a new value.
    pub fn next(self: Date) Date {
        var d = self;
        d.day += 1;
        if (d.day > daysInMonth(d.year, d.month)) {
            d.day = 1;
            d.month += 1;
            if (d.month > 12) {
                d.month = 1;
                d.year += 1;
            }
        }
        return d;
    }

    /// Advance self in place by n days.
    pub fn advance(self: *Date, n: u32) void {
        var i: u32 = 0;
        while (i < n) : (i += 1) self.* = self.next();
    }

    pub fn isPayday(self: Date) bool {
        return self.day == 1;
    }
};

test "leap years" {
    try std.testing.expect(Date.isLeapYear(3024));
    try std.testing.expect(!Date.isLeapYear(3025));
    try std.testing.expect(!Date.isLeapYear(3100));
    try std.testing.expect(Date.isLeapYear(3200));
}

test "next rolls over months and years" {
    var d: Date = .{ .year = 3024, .month = 2, .day = 28 };
    d = d.next();
    try std.testing.expectEqual(Date{ .year = 3024, .month = 2, .day = 29 }, d);
    d = .{ .year = 3025, .month = 12, .day = 31 };
    try std.testing.expectEqual(Date{ .year = 3026, .month = 1, .day = 1 }, d.next());
}

test "advance mutates in place" {
    var d = Date.campaign_default;
    d.advance(31);
    try std.testing.expectEqual(Date{ .year = 3025, .month = 2, .day = 1 }, d);
    try std.testing.expect(d.isPayday());
    d.advance(1);
    try std.testing.expect(!d.isPayday());
}
