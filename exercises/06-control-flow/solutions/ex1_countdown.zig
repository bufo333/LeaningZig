//! Chapter 06, exercise 1: while, for and if together.
//! Run with:  zig run ex1_countdown.zig
//! Expected output (on stderr):
//!   T-5 T-4 T-3 T-2 T-1 launch
//!   1 2 fizz 4 buzz fizz 7 8 fizz buzz 11 fizz 13 14 fizzbuzz
const std = @import("std");

pub fn main() void {
    var t: u32 = 5;
    while (t > 0) : (t -= 1) {
        std.debug.print("T-{d} ", .{t});
    }
    std.debug.print("launch\n", .{});

    for (1..16) |n| {
        if (n % 15 == 0) {
            std.debug.print("fizzbuzz", .{});
        } else if (n % 3 == 0) {
            std.debug.print("fizz", .{});
        } else if (n % 5 == 0) {
            std.debug.print("buzz", .{});
        } else {
            std.debug.print("{d}", .{n});
        }
        if (n == 15) {
            std.debug.print("\n", .{});
        } else {
            std.debug.print(" ", .{});
        }
    }
}
