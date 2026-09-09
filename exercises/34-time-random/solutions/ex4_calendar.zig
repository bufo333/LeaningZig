//! Chapter 34, exercise 4: civil calendar arithmetic by hand.
//! Run with:  zig test ex4_calendar.zig
//! Goal: implement `daysInMonth`, `next`, `addDays` and `dayOfYear` so
//! the tests pass. Leap years: divisible by 4, except centuries, except
//! every 400th year.

const std = @import("std");

pub const Date = struct {
    year: u16,
    month: u8, // 1..12
    day: u8, // 1..31

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

    pub fn addDays(self: Date, n: u32) Date {
        var d = self;
        for (0..n) |_| d = d.next();
        return d;
    }

    /// 1 for January 1st, 365 or 366 for December 31st.
    pub fn dayOfYear(self: Date) u16 {
        var total: u16 = self.day;
        var m: u8 = 1;
        while (m < self.month) : (m += 1) total += daysInMonth(self.year, m);
        return total;
    }
};

test "leap year rules" {
    try std.testing.expect(Date.isLeapYear(2024));
    try std.testing.expect(!Date.isLeapYear(2023));
    try std.testing.expect(!Date.isLeapYear(1900));
    try std.testing.expect(Date.isLeapYear(2000));
    try std.testing.expect(Date.isLeapYear(3024));
}

test "february length" {
    try std.testing.expectEqual(@as(u8, 29), Date.daysInMonth(3024, 2));
    try std.testing.expectEqual(@as(u8, 28), Date.daysInMonth(3025, 2));
}

test "month and year rollover" {
    const d: Date = .{ .year = 3025, .month = 12, .day = 31 };
    try std.testing.expectEqual(Date{ .year = 3026, .month = 1, .day = 1 }, d.next());
    const f: Date = .{ .year = 3024, .month = 2, .day = 28 };
    try std.testing.expectEqual(Date{ .year = 3024, .month = 2, .day = 29 }, f.next());
}

test "addDays crosses months" {
    const d: Date = .{ .year = 3025, .month = 1, .day = 1 };
    try std.testing.expectEqual(Date{ .year = 3025, .month = 2, .day = 15 }, d.addDays(45));
    try std.testing.expectEqual(Date{ .year = 3026, .month = 1, .day = 1 }, d.addDays(365));
}

test "dayOfYear" {
    try std.testing.expectEqual(@as(u16, 1), (Date{ .year = 3025, .month = 1, .day = 1 }).dayOfYear());
    try std.testing.expectEqual(@as(u16, 365), (Date{ .year = 3025, .month = 12, .day = 31 }).dayOfYear());
    try std.testing.expectEqual(@as(u16, 366), (Date{ .year = 3024, .month = 12, .day = 31 }).dayOfYear());
}
