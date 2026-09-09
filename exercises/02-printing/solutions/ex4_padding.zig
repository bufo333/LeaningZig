//! Chapter 02, exercise 4: the same number, five ways.
//! Run with:  zig run ex4_padding.zig
//! Expected output (on stderr):
//!   [255] [00255] [  255] [ff] [0xFF] [11111111]
const std = @import("std");

pub fn main() void {
    const n: u8 = 255;
    std.debug.print("[{d}] [{d:0>5}] [{d:>5}] [{x}] [0x{X}] [{b}]\n", .{ n, n, n, n, n, n });
}
