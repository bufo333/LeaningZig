//! Chapter 21, exercise 4: a roster of structs.
//! Run with:  zig test ex4_roster.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Merc = struct { name: []const u8, gunnery: u8, wounds: u8 };

const Roster = struct {
    mercs: std.ArrayList(Merc) = .empty,

    fn deinit(self: *Roster, gpa: std.mem.Allocator) void {
        self.mercs.deinit(gpa);
    }

    fn hire(self: *Roster, gpa: std.mem.Allocator, name: []const u8, gunnery: u8) !void {
        _ = self; _ = gpa; _ = name; _ = gunnery;
        // TODO: append a Merc with zero wounds.
    }

    /// Every merc takes one wound. Must mutate in place.
    fn battle(self: *Roster) void {
        _ = self;
        // TODO: iterate by pointer.
    }

    /// Release every merc whose gunnery is worse (higher) than `limit`, keeping order.
    fn releaseWorseThan(self: *Roster, limit: u8) usize {
        _ = self; _ = limit;
        // TODO
    }

    /// Pointer to the best shot (lowest gunnery), or null if empty.
    fn best(self: *Roster) ?*Merc {
        _ = self;
        // TODO
    }
};

test "hire, fight, release" {
    const a = std.testing.allocator;
    var r: Roster = .{};
    defer r.deinit(a);
    try r.hire(a, "Kell", 2);
    try r.hire(a, "Rookie", 6);
    try r.hire(a, "Natasha", 1);
    r.battle();
    try std.testing.expectEqual(@as(u8, 1), r.mercs.items[1].wounds);
    try std.testing.expectEqual(@as(usize, 1), r.releaseWorseThan(4));
    try std.testing.expectEqualStrings("Kell", r.mercs.items[0].name);
    try std.testing.expectEqualStrings("Natasha", r.mercs.items[1].name);
}

test "best is a live pointer" {
    const a = std.testing.allocator;
    var r: Roster = .{};
    defer r.deinit(a);
    try std.testing.expect(r.best() == null);
    try r.hire(a, "Kell", 2);
    try r.hire(a, "Natasha", 1);
    r.best().?.wounds = 9; // writes through to the list
    try std.testing.expectEqual(@as(u8, 9), r.mercs.items[1].wounds);
}
