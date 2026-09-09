//! Chapter 12, exercise 2: defaults, nesting and a format method.
//! Run with:  zig test ex2_unit.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Armor = struct { front: u16, rear: u16 };

const Unit = struct {
    name: []const u8,
    tons: u8,
    armor: Armor = .{ .front = 0, .rear = 0 },
    pilot: ?[]const u8 = null,
    destroyed: bool = false,

    pub fn totalArmor(self: Unit) u32 {
        return @as(u32, self.armor.front) + self.armor.rear;
    }

    /// Apply damage to the front armor; anything left over destroys the unit.
    pub fn hitFront(self: *Unit, dmg: u16) void {
        if (dmg >= self.armor.front) {
            self.armor.front = 0;
            self.destroyed = true;
        } else {
            self.armor.front -= dmg;
        }
    }

    pub fn format(self: Unit, w: *std.Io.Writer) std.Io.Writer.Error!void {
        const a = self.armor;
        try w.print("{s} ({d}t, {d}/{d})", .{ self.name, self.tons, a.front, a.rear });
        if (self.pilot) |p| try w.print(" piloted by {s}", .{p});
        if (self.destroyed) try w.writeAll(" [DESTROYED]");
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
