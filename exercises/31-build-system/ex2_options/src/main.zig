//! Chapter 31, exercise 2: -D flags become compile-time constants.
//! Run with:  zig build run -Ddifficulty=hard -Dfunds=500000 -Dcheats
//!            zig build test   (inside ex2_options/)
const std = @import("std");
const build_options = @import("build_options");

pub fn startingFunds() u32 {
    // Hard mode starts with half the money.
    return if (std.mem.eql(u8, build_options.difficulty, "hard")) build_options.start_funds / 2 else build_options.start_funds;
}

pub fn main() void {
    std.debug.print("difficulty {s}, funds {d}, cheats {}\n", .{ build_options.difficulty, startingFunds(), build_options.cheats });
    if (build_options.cheats) std.debug.print("cheat commands enabled\n", .{});
}

test "defaults" {
    // With no -D flags this is what the build script chose.
    try std.testing.expect(build_options.start_funds > 0);
    try std.testing.expect(startingFunds() <= build_options.start_funds);
}
