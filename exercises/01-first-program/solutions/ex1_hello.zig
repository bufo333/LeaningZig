//! Chapter 01, exercise 1: hello, world by hand.
//! Run with:  zig run ex1_hello.zig
//! Expected output (on stderr):
//!   Hello, world!
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, world!\n", .{});
}
