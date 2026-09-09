//! Chapter 03, exercise 4: swap two variables and count mutations.
//! Run with:  zig run ex4_swap.zig
//! Expected output (on stderr):
//!   before: a=3 b=7
//!   after:  a=7 b=3
//!   swaps: 1
//! Use one temporary. Every variable must be declared with the right keyword.
const std = @import("std");

pub fn main() void {
    const a: u32 = 3;
    const b: u32 = 7;
    const swaps: u32 = 0;
    std.debug.print("before: a={d} b={d}\n", .{ a, b });
    // TODO: swap a and b using a temporary, and add one to swaps.
    std.debug.print("after:  a={d} b={d}\n", .{ a, b });
    std.debug.print("swaps: {d}\n", .{swaps});
}
