//! Chapter 02, exercise 2: an aligned table.
//! Run with:  zig run ex2_table.zig
//! Expected output (on stderr):
//!   Unit         Tons   Price
//!   Locust         20 1512000
//!   Shadow Hawk    55 4701000
//!   Atlas         100 9626000
const std = @import("std");

pub fn main() void {
    std.debug.print("{s:<12} {s:>4} {s:>7}\n", .{ "Unit", "Tons", "Price" });
    std.debug.print("{s:<12} {d:>4} {d:>7}\n", .{ "Locust", 20, 1_512_000 });
    std.debug.print("{s:<12} {d:>4} {d:>7}\n", .{ "Shadow Hawk", 55, 4_701_000 });
    std.debug.print("{s:<12} {d:>4} {d:>7}\n", .{ "Atlas", 100, 9_626_000 });
}
