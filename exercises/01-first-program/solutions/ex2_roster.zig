//! Chapter 01, exercise 2: three lines, one placeholder each.
//! Run with:  zig run ex2_roster.zig
//! Expected output (on stderr):
//!   Company: Grey Death Legion
//!   Commander: Carlyle
//!   Units: 4
const std = @import("std");

pub fn main() void {
    const company = "Grey Death Legion";
    const commander = "Carlyle";
    const units: u32 = 4;
    std.debug.print("Company: {s}\n", .{company});
    std.debug.print("Commander: {s}\n", .{commander});
    std.debug.print("Units: {d}\n", .{units});
}
