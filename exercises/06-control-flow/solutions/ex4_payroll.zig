//! Chapter 06, exercise 4: a month of payroll, day by day.
//! Run with:  zig run ex4_payroll.zig
//! Expected output (on stderr):
//!   day 7: paid 200000, funds 385000
//!   day 14: paid 200000, funds 270000
//!   day 21: paid 200000, funds 155000
//!   day 25: DEBT (-25000), stopping
const std = @import("std");

pub fn main() void {
    var funds: i64 = 500_000;
    const daily_cost: i64 = 45_000;
    const weekly_pay: i64 = 200_000;
    var day: u32 = 1;
    while (day <= 30) : (day += 1) {
        funds -= daily_cost;
        if (day % 7 == 0) {
            funds += weekly_pay;
            std.debug.print("day {d}: paid {d}, funds {d}\n", .{ day, weekly_pay, funds });
        }
        if (funds < 0) {
            std.debug.print("day {d}: DEBT ({d}), stopping\n", .{ day, funds });
            break;
        }
    }
}
