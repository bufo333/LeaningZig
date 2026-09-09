//! Chapter 34, exercise 4: civil calendar arithmetic by hand.
//! Run with:  zig test ex4_calendar.zig
//! Goal: implement `daysInMonth`, `next`, `addDays` and `dayOfYear` so
//! the tests pass. Leap years: divisible by 4, except centuries, except
//! every 400th year.
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

pub const Date = struct {
    year: u16,
    month: u8, // 1..12
    day: u8, // 1..31

    pub fn isLeapYear(year: u16) bool {
        // TODO: divisible by 4, except centuries, except every 400th year
        _ = year;
        return false;
    }

    pub fn daysInMonth(year: u16, month: u8) u8 {
        // TODO: 31, 30, or 28/29 for February
        _ = year;
        _ = month;
        return 30;
    }

    pub fn next(self: Date) Date {
        // TODO: add one day, rolling over month and year
        return self;
    }

    pub fn addDays(self: Date, n: u32) Date {
        // TODO: call next n times
        _ = n;
        return self;
    }

    /// 1 for January 1st, 365 or 366 for December 31st.
    pub fn dayOfYear(self: Date) u16 {
        // TODO: sum the months before this one, plus the day
        return self.day;
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
