//! Chapter 12, exercise 1: a Date struct with methods.
//! Run with:  zig test ex1_date.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const Date = struct {
    year: u16,
    month: u8, // 1..12
    day: u8, // 1..31

    pub const campaign_default: Date = .{ .year = 3025, .month = 1, .day = 1 };

    /// Divisible by 4, except centuries, except every fourth century.
    pub fn isLeapYear(year: u16) bool {
        _ = year;
        // TODO
    }

    pub fn daysInMonth(year: u16, month: u8) u8 {
        _ = year;
        _ = month;
        // TODO: a switch on month; February depends on isLeapYear
    }

    /// The day after self, as a new value. Do not mutate self.
    pub fn next(self: Date) Date {
        _ = self;
        // TODO
    }

    /// Advance self in place by n days. Reuse next().
    pub fn advance(self: *Date, n: u32) void {
        _ = self;
        _ = n;
        // TODO
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
