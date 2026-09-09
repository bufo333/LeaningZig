//! Chapter 25, exercise 3: inline for over struct fields.
//! Run with:  zig test ex3_fields.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// Sum every integer field of a struct; skip fields of other types.
/// Fields of an anonymous literal like .{ .a = 1 } have type comptime_int, so accept that too.
fn sumIntFields(value: anytype) i64 {
    _ = value;
    // TODO
}

/// How many fields of type `bool` does the struct type T have? Computed at compile time.
fn boolFieldCount(comptime T: type) usize {
    // TODO
}

/// The name of the first field whose type is `Wanted`, or null.
fn firstFieldOfType(comptime T: type, comptime Wanted: type) ?[]const u8 {
    // TODO
}

const Unit = struct { tons: u32, armor: u16, name: []const u8, destroyed: bool, salvage: bool, bv: i32 };

test "sum" {
    const u: Unit = .{ .tons = 100, .armor = 300, .name = "Atlas", .destroyed = false, .salvage = true, .bv = -5 };
    try std.testing.expectEqual(@as(i64, 395), sumIntFields(u));
    try std.testing.expectEqual(@as(i64, 3), sumIntFields(.{ .a = 1, .b = 2 }));
}

test "counts at compile time" {
    const n = comptime boolFieldCount(Unit);
    const flags: [n]bool = @splat(false);
    try std.testing.expectEqual(@as(usize, 2), flags.len);
}

test "first field of type" {
    try std.testing.expectEqualStrings("armor", (comptime firstFieldOfType(Unit, u16)).?);
    try std.testing.expectEqualStrings("destroyed", (comptime firstFieldOfType(Unit, bool)).?);
    try std.testing.expect(comptime firstFieldOfType(Unit, f64) == null);
}
