//! Chapter 17, exercise 1: predict the order.
//! Run with:  zig run ex1_order.zig
//! Goal: before running, write down the order of the lines. Then run it.
//! Expected output:
//!   enter mission
//!     enter hangar
//!     leave hangar
//!   mission step 1
//!   mission step 2
//!   mission step 3
//!   leave mission (second defer)
//!   leave mission (first defer)
const std = @import("std");

pub fn main() void {
    std.debug.print("enter mission\n", .{});
    defer std.debug.print("leave mission (first defer)\n", .{});
    defer std.debug.print("leave mission (second defer)\n", .{});
    {
        std.debug.print("  enter hangar\n", .{});
        defer std.debug.print("  leave hangar\n", .{});
    }
    var i: u32 = 1;
    while (i <= 3) : (i += 1) {
        std.debug.print("mission step {d}\n", .{i});
    }
}
