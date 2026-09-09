//! Chapter 06, exercise 4: a month of payroll, day by day.
//! Run with:  zig run ex4_payroll.zig
//! Expected output (on stderr):
//!   day 7: paid 200000, funds 385000
//!   day 14: paid 200000, funds 270000
//!   day 21: paid 200000, funds 155000
//!   day 25: DEBT (-25000), stopping
//! Rules: funds start at 500000. Every day costs 45000. Every seventh day the
//! contract pays 200000 (after that day's cost) and you print the "paid" line.
//! The moment funds drop below zero, print the DEBT line and leave the loop.
//! Run for at most 30 days.
const std = @import("std");

pub fn main() void {
    var funds: i64 = 500_000;
    // TODO
    funds += 0;
}
