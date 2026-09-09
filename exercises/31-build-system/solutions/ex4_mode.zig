//! Chapter 31, exercise 4: see the optimize mode from inside the program.
//! Run with:  zig run ex4_mode.zig
//! Then try:  zig run -O ReleaseFast ex4_mode.zig
//! Expected output (Debug):
//!   mode: Debug
//!   safety checks: on
//!   overflow check: caught error.Overflow
const std = @import("std");
const builtin = @import("builtin");

pub fn main() void {
    std.debug.print("mode: {s}\n", .{@tagName(builtin.mode)});
    const safe = switch (builtin.mode) {
        .Debug, .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
    std.debug.print("safety checks: {s}\n", .{if (safe) "on" else "off"});
    // Never rely on a panic to catch overflow: use the checked builtin.
    const big: u8 = 250;
    if (std.math.add(u8, big, 10)) |v| {
        std.debug.print("overflow check: {d}\n", .{v});
    } else |err| {
        std.debug.print("overflow check: caught {s}\n", .{@errorName(err)});
    }
}
