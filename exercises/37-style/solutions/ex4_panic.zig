//! Chapter 37, exercise 4: read the panic, fix the bug.
//! Run with:  zig run ex4_panic.zig
//! Goal: the starter panics with "index out of bounds" and, after you fix
//! that, with "integer overflow". Use the stack trace to find each line,
//! then fix the logic (not the safety check). Expected output:
//!   Grayson: 1500
//!   Lori: 1500
//!   Clay: 800
//!   total 3800
//!   average 1266

const std = @import("std");

const names = [_][]const u8{ "Grayson", "Lori", "Clay" };
const pay = [_]u16{ 1500, 1500, 800 };

pub fn main() void {
    // was `i <= names.len`: one past the end
    var i: usize = 0;
    while (i < names.len) : (i += 1) {
        std.debug.print("{s}: {d}\n", .{ names[i], pay[i] });
    }
    // was `var total: u16 = 0`: 1500 + 1500 + 800 overflows u16
    var total: u32 = 0;
    for (pay) |p| total += p;
    std.debug.print("total {d}\n", .{total});
    std.debug.print("average {d}\n", .{total / pay.len});
}
