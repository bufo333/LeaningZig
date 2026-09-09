//! Chapter 02, exercise 3: a multi-line banner with a placeholder inside.
//! Run with:  zig run ex3_banner.zig
//! Expected output (on stderr):
//!   +----------------------+
//!   | IRON LEDGER   day 12 |
//!   | funds: {not a hole}  |
//!   | "trust the ledger"   |
//!   +----------------------+
//! Use a multi-line string literal (lines starting with \\). Note the literal
//! braces on the third line and the double quotes on the fourth.
const std = @import("std");

pub fn main() void {
    const day: u32 = 12;
    // TODO: build the banner as one multi-line string and print it with day.
    _ = day;
}
