//! Chapter 21, exercise 4: a roster of structs.
//! Run with:  zig test ex4_roster.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Merc = struct { name: []const u8, gunnery: u8, wounds: u8 };

const Roster = struct {
    mercs: std.ArrayList(Merc) = .empty,

    fn deinit(self: *Roster, gpa: std.mem.Allocator) void {
        self.mercs.deinit(gpa);
    }

    fn hire(self: *Roster, gpa: std.mem.Allocator, name: []const u8, gunnery: u8) !void {
        try self.mercs.append(gpa, .{ .name = name, .gunnery = gunnery, .wounds = 0 });
    }

    /// Every merc takes one wound. Must mutate in place.
    fn battle(self: *Roster) void {
        for (self.mercs.items) |*m| m.wounds += 1;
    }

    /// Release every merc whose gunnery is worse (higher) than `limit`, keeping order.
    fn releaseWorseThan(self: *Roster, limit: u8) usize {
        var released: usize = 0;
        var i: usize = 0;
        while (i < self.mercs.items.len) {
            if (self.mercs.items[i].gunnery > limit) {
                _ = self.mercs.orderedRemove(i);
                released += 1;
            } else i += 1;
        }
        return released;
    }

    /// Pointer to the best shot (lowest gunnery), or null if empty.
    fn best(self: *Roster) ?*Merc {
        if (self.mercs.items.len == 0) return null;
        var b = &self.mercs.items[0];
        for (self.mercs.items[1..]) |*m| if (m.gunnery < b.gunnery) {
            b = m;
        };
        return b;
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
