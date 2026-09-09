//! Chapter 31, exercise 1: the executable that imports "dice".
//! Run with:  zig build run -- 3025   (inside ex1_two_modules/)
const std = @import("std");
const dice = @import("dice");

pub fn main(init: std.process.Init) !void {
    var it = std.process.Args.Iterator.init(init.minimal.args);
    _ = it.next();
    const seed = try std.fmt.parseInt(u64, it.next() orelse "1", 10);
    const r = dice.roll2d6(seed);
    std.debug.print("seed {d}: {d} + {d} = {d}{s}\n", .{ seed, r.dice[0], r.dice[1], r.total, if (dice.isSnakeEyes(r)) " (snake eyes!)" else "" });
}

test "exe sees the library" {
    try std.testing.expect(dice.roll2d6(1).total <= 12);
}
