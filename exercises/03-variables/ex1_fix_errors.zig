//! Chapter 03, exercise 1: make the compiler happy.
//! Run with:  zig run ex1_fix_errors.zig
//! Expected output (on stderr):
//!   4 units, 250 tons, avg 62
//! This file has four compile errors of the kinds shown in the chapter
//! (unused local, never-mutated var, shadowing, assigning to a const).
//! Fix each one in the smallest way that keeps the meaning. Do not delete
//! the print at the bottom.
const std = @import("std");

pub fn main() void {
    const units: u32 = 4;
    var total: u32 = 250;
    const commander = "Carlyle";
    const average = total / units;
    {
        const average = 0;
        _ = average;
    }
    units = 4;
    std.debug.print("{d} units, {d} tons, avg {d}\n", .{ units, total, average });
}
