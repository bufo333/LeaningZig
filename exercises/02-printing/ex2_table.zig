//! Chapter 02, exercise 2: an aligned table.
//! Run with:  zig run ex2_table.zig
//! Expected output (on stderr):
//!   Unit         Tons   Price
//!   Locust         20 1512000
//!   Shadow Hawk    55 4701000
//!   Atlas         100 9626000
//! The name column is 12 wide and left-aligned, tons is 4 wide right-aligned,
//! price is 7 wide right-aligned, with a single space between columns.
const std = @import("std");

pub fn main() void {
    // TODO: four print calls. The header row uses {s} three times.
    std.debug.print("TODO\n", .{});
}
