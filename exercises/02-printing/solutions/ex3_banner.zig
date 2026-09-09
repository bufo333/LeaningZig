//! Chapter 02, exercise 3: a multi-line banner with a placeholder inside.
//! Run with:  zig run ex3_banner.zig
//! Expected output (on stderr):
//!   +----------------------+
//!   | IRON LEDGER   day 12 |
//!   | funds: {not a hole}  |
//!   | "trust the ledger"   |
//!   +----------------------+
const std = @import("std");

pub fn main() void {
    const day: u32 = 12;
    const banner =
        \\+----------------------+
        \\| IRON LEDGER   day {d} |
        \\| funds: {{not a hole}}  |
        \\| "trust the ledger"   |
        \\+----------------------+
        \\
    ;
    std.debug.print(banner, .{day});
}
