//! Chapter 02, exercise 1: one line, five placeholders.
//! Run with:  zig run ex1_placeholders.zig
//! Expected output (on stderr):
//!   Atlas (grade A) weighs 100 tons, hex 64, binary 1100100
//! This starter does not compile until you use every constant.
const std = @import("std");

pub fn main() void {
    const name = "Atlas";
    const grade: u8 = 'A';
    const tonnage: u32 = 100;
    // TODO: one std.debug.print call that produces the line in the header.
    // You will need {s}, {c}, {d}, {x} and {b}. tonnage appears three times.
}
