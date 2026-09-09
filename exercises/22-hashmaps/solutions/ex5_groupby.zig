//! Chapter 22, exercise 5: group names by role, owning the keys.
//! Run with:  zig test ex5_groupby.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Groups = struct {
    map: std.StringArrayHashMapUnmanaged(std.ArrayList([]const u8)) = .empty,

    /// Free every duped key and every list, then the map.
    fn deinit(self: *Groups, gpa: std.mem.Allocator) void {
        for (self.map.keys(), self.map.values()) |k, *list| {
            gpa.free(k);
            list.deinit(gpa);
        }
        self.map.deinit(gpa);
    }

    /// `role` may be a temporary; the map must own its own copy of the key.
    fn add(self: *Groups, gpa: std.mem.Allocator, role: []const u8, name: []const u8) !void {
        const gop = try self.map.getOrPut(gpa, role);
        if (!gop.found_existing) {
            gop.key_ptr.* = try gpa.dupe(u8, role);
            gop.value_ptr.* = .empty;
        }
        try gop.value_ptr.append(gpa, name);
    }

    fn members(self: Groups, role: []const u8) []const []const u8 {
        const list = self.map.get(role) orelse return &.{};
        return list.items;
    }
};

test "group by role with temporary keys" {
    const a = std.testing.allocator;
    var g: Groups = .{};
    defer g.deinit(a);

    var buf: [16]u8 = undefined;
    const rows = [_]struct { role: []const u8, name: []const u8 }{
        .{ .role = "pilot", .name = "Kell" },
        .{ .role = "tech", .name = "Sato" },
        .{ .role = "pilot", .name = "Natasha" },
    };
    for (rows) |r| {
        // Build the key in a reused buffer so it is definitely temporary.
        const key = try std.fmt.bufPrint(&buf, "{s}", .{r.role});
        try g.add(a, key, r.name);
        @memset(&buf, 0);
    }
    try std.testing.expectEqual(@as(usize, 2), g.members("pilot").len);
    try std.testing.expectEqualStrings("Natasha", g.members("pilot")[1]);
    try std.testing.expectEqual(@as(usize, 1), g.members("tech").len);
    try std.testing.expectEqual(@as(usize, 0), g.members("medic").len);
    try std.testing.expectEqualStrings("pilot", g.map.keys()[0]);
}
