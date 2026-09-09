//! Chapter 25, exercise 1: a table computed by the compiler.
//! Run with:  zig test ex1_powers.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// powers[i] == 2^i for i in 0..64, filled in at compile time.
const powers: [64]u64 = blk: {
    var t: [64]u64 = undefined;
    for (&t, 0..) |*e, i| e.* = @as(u64, 1) << @intCast(i);
    break :blk t;
};

// Checks that run while compiling; a failure is a build error, not a test failure.
comptime {
    std.debug.assert(powers[0] == 1);
    std.debug.assert(powers[63] == 1 << 63);
}

/// The smallest i such that 2^i >= n, or null if n is 0 or too large.
fn ceilLog2(n: u64) ?u6 {
    _ = n;
    // TODO
}

test "table" {
    try std.testing.expectEqual(@as(u64, 1024), powers[10]);
    try std.testing.expectEqual(@as(u64, 1 << 40), powers[40]);
}

test "ceilLog2" {
    try std.testing.expectEqual(@as(?u6, 0), ceilLog2(1));
    try std.testing.expectEqual(@as(?u6, 3), ceilLog2(8));
    try std.testing.expectEqual(@as(?u6, 4), ceilLog2(9));
    try std.testing.expectEqual(@as(?u6, null), ceilLog2(0));
    try std.testing.expectEqual(@as(?u6, null), ceilLog2(std.math.maxInt(u64)));
}

test "the table is a compile-time constant" {
    // If this were not comptime-known, the array length below would not compile.
    const n = comptime powers[3];
    const arr: [n]u8 = @splat(7);
    try std.testing.expectEqual(@as(usize, 8), arr.len);
}
