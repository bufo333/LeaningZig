//! Chapter 03, exercise 2: give each value the type the tests expect.
//! Run with:  zig test ex2_types.zig
//! Goal: make every test pass by changing only the declarations marked TODO.
//! Hint: @TypeOf(x) is the type of x, and the tests compare types directly.
const std = @import("std");

// TODO: pick the right annotation (or none) for each of these.
const seats = 4;
const tonnage = 55;
const ratio = 0.5;
const funds = 1_000_000;

test "seats is a u8" {
    try std.testing.expectEqual(u8, @TypeOf(seats));
}

test "tonnage is a u32" {
    try std.testing.expectEqual(u32, @TypeOf(tonnage));
}

test "ratio is an f64" {
    try std.testing.expectEqual(f64, @TypeOf(ratio));
}

test "funds is an i64 and can go negative" {
    try std.testing.expectEqual(i64, @TypeOf(funds));
    const after: i64 = funds - 2_000_000;
    try std.testing.expect(after < 0);
}
