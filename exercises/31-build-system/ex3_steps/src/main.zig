//! Chapter 31, exercise 3: custom build steps.
//! Run with:  zig build demo ; zig build run -- x y ; zig build test
//!            (inside ex3_steps/)
const std = @import("std");

pub fn countArgs(args: std.process.Args) usize {
    var it = std.process.Args.Iterator.init(args);
    _ = it.next();
    var n: usize = 0;
    while (it.next()) |_| n += 1;
    return n;
}

pub fn main(init: std.process.Init) void {
    std.debug.print("{d} argument(s)\n", .{countArgs(init.minimal.args)});
}

test "always passes" {
    try std.testing.expect(true);
}
