//! Chapter 12, exercise 2: defaults, nesting and a format method.
//! Run with:  zig test ex2_unit.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const Armor = struct { front: u16, rear: u16 };

const Unit = struct {
    name: []const u8,
    tons: u8,
    // TODO: armor with a default of 0/0, an optional pilot name defaulting
    // to null, and a destroyed flag defaulting to false.

    pub fn totalArmor(self: Unit) u32 {
        _ = self;
        // TODO: mind the result type; two u16 can overflow a u16
    }

    /// Apply damage to the front armor; anything left over destroys the unit.
    pub fn hitFront(self: *Unit, dmg: u16) void {
        _ = self;
        _ = dmg;
        // TODO
    }

    /// "Name (Nt, front/rear)", then " piloted by X" if there is a pilot,
    /// then " [DESTROYED]" if destroyed.
    pub fn format(self: Unit, w: *std.Io.Writer) std.Io.Writer.Error!void {
        _ = self;
        _ = w;
        // TODO
    }
};

test "defaults" {
    const u = Unit{ .name = "Locust", .tons = 20 };
    try std.testing.expectEqual(@as(u32, 0), u.totalArmor());
    try std.testing.expectEqual(@as(?[]const u8, null), u.pilot);
    try std.testing.expect(!u.destroyed);
}

test "damage" {
    var u = Unit{ .name = "Atlas", .tons = 100, .armor = .{ .front = 47, .rear = 14 } };
    u.hitFront(10);
    try std.testing.expectEqual(@as(u32, 51), u.totalArmor());
    try std.testing.expect(!u.destroyed);
    u.hitFront(40);
    try std.testing.expect(u.destroyed);
    try std.testing.expectEqual(@as(u16, 0), u.armor.front);
}

test "format" {
    var buf: [96]u8 = undefined;
    var u = Unit{
        .name = "Atlas",
        .tons = 100,
        .armor = .{ .front = 47, .rear = 14 },
        .pilot = "Kai",
    };
    try std.testing.expectEqualStrings(
        "Atlas (100t, 47/14) piloted by Kai",
        try std.fmt.bufPrint(&buf, "{f}", .{u}),
    );
    u.hitFront(99);
    try std.testing.expectEqualStrings(
        "Atlas (100t, 0/14) piloted by Kai [DESTROYED]",
        try std.fmt.bufPrint(&buf, "{f}", .{u}),
    );
}
