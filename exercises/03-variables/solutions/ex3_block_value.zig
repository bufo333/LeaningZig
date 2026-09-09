//! Chapter 03, exercise 3: compute a value with a labeled block.
//! Run with:  zig test ex3_block_value.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Return the weight class name for a BattleMech tonnage:
/// up to 35 "light", up to 55 "medium", up to 75 "heavy", otherwise "assault".
fn weightClass(tonnage: u32) []const u8 {
    const class = blk: {
        if (tonnage <= 35) break :blk "light";
        if (tonnage <= 55) break :blk "medium";
        if (tonnage <= 75) break :blk "heavy";
        break :blk "assault";
    };
    return class;
}

test "light" {
    try std.testing.expectEqualStrings("light", weightClass(20));
    try std.testing.expectEqualStrings("light", weightClass(35));
}

test "medium" {
    try std.testing.expectEqualStrings("medium", weightClass(36));
    try std.testing.expectEqualStrings("medium", weightClass(55));
}

test "heavy and assault" {
    try std.testing.expectEqualStrings("heavy", weightClass(75));
    try std.testing.expectEqualStrings("assault", weightClass(100));
}
