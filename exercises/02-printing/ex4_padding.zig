//! Chapter 02, exercise 4: the same number, five ways.
//! Run with:  zig run ex4_padding.zig
//! Expected output (on stderr):
//!   [255] [00255] [  255] [ff] [0xFF] [11111111]
const std = @import("std");

pub fn main() void {
    const n: u8 = 255;
    // TODO: print n as plain decimal, zero-padded to 5, space-padded to 5
    // (right-aligned), lowercase hex, uppercase hex with a 0x prefix, and binary.
    _ = n;
}
