//! Chapter 35, exercise 1: three libc functions by hand.
//! Run with:  zig run -lc ex1_libc.zig
//! Goal: declare strlen, getpid and toupper with `extern fn`, call them,
//! and print the results. Expected output (pid differs):
//!   strlen("Grayson Carlyle") = 15
//!   pid = 12345 (positive: true)
//!   toupper('m') = M
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

// TODO: declare strlen, getpid and toupper with `extern fn`.

pub fn main() void {
    const name: [*:0]const u8 = "Grayson Carlyle";
    // TODO: print strlen(name), getpid(), and toupper('m') as shown in the header
    _ = name;
}
