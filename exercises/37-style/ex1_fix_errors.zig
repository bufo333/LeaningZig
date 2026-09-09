//! Chapter 37, exercise 1: fix six compile errors.
//! Run with:  zig run ex1_fix_errors.zig
//! Goal: the starter has six errors (unused constant, shadowing, missing
//! switch case, type mismatch, try in a non-error function, comptime
//! overflow). Fix them one at a time, re-running after each. Expected
//! output:
//!   mekwarrior earns 1500
//!   tech earns 800
//!   medic earns 400
//!   parsed 42
//!   days in the year: 365
//! STARTER: this file has six compile errors on purpose.

const std = @import("std");

const Role = enum { mekwarrior, tech, medic };

fn salary(r: Role) i64 {
    return switch (r) {
        .mekwarrior => 1500,
        .tech => 800,
    };
}

fn parse(s: []const u8) i32 {
    return try std.fmt.parseInt(i32, s, 10);
}

fn label(funds: i64) []const u8 {
    return if (funds > 0) "solvent" else 0;
}

pub fn main() !void {
    const unused = 5;
    const roles = [_]Role{ .mekwarrior, .tech, .medic };
    for (roles) |r| {
        std.debug.print("{s} earns {d}\n", .{ @tagName(r), salary(r) });
    }
    const n = try parse("42");
    for (0..1) |n| {
        std.debug.print("parsed {d}\n", .{n});
    }
    _ = label(n);
    const days: u8 = 365;
    std.debug.print("days in the year: {d}\n", .{days});
}
