//! Chapter 02, exercise 1: one line, five placeholders.
//! Run with:  zig run ex1_placeholders.zig
//! Expected output (on stderr):
//!   Atlas (grade A) weighs 100 tons, hex 64, binary 1100100
const std = @import("std");

pub fn main() void {
    const name = "Atlas";
    const grade: u8 = 'A';
    const tonnage: u32 = 100;
    std.debug.print("{s} (grade {c}) weighs {d} tons, hex {x}, binary {b}\n", .{
        name, grade, tonnage, tonnage, tonnage,
    });
}
