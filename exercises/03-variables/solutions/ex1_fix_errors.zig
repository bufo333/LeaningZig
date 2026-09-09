//! Chapter 03, exercise 1: make the compiler happy.
//! Run with:  zig run ex1_fix_errors.zig
//! Expected output (on stderr):
//!   4 units, 250 tons, avg 62
const std = @import("std");

pub fn main() void {
    const units: u32 = 4;
    const total: u32 = 250; // was var, never mutated
    const commander = "Carlyle";
    _ = commander; // was unused
    const average = total / units;
    {
        const inner_average = 0; // was shadowing `average`
        _ = inner_average;
    }
    // `units = 4;` removed: you cannot assign to a const
    std.debug.print("{d} units, {d} tons, avg {d}\n", .{ units, total, average });
}
