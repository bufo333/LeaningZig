//! Chapter 03, exercise 4: swap two variables and count mutations.
//! Run with:  zig run ex4_swap.zig
//! Expected output (on stderr):
//!   before: a=3 b=7
//!   after:  a=7 b=3
//!   swaps: 1
const std = @import("std");

pub fn main() void {
    var a: u32 = 3;
    var b: u32 = 7;
    var swaps: u32 = 0;
    std.debug.print("before: a={d} b={d}\n", .{ a, b });
    const tmp = a;
    a = b;
    b = tmp;
    swaps += 1;
    std.debug.print("after:  a={d} b={d}\n", .{ a, b });
    std.debug.print("swaps: {d}\n", .{swaps});
}
