//! Chapter 12, exercise 3: a struct that holds an array of structs.
//! Run with:  zig test ex3_lance.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Mek = struct {
    name: []const u8,
    tons: u8,
    ready: bool = true,
};

const Lance = struct {
    name: []const u8,
    meks: [4]Mek,

    const Self = @This();

    pub fn tonnage(self: Self) u32 {
        var t: u32 = 0;
        for (self.meks) |m| t += m.tons;
        return t;
    }

    pub fn readyCount(self: Self) usize {
        var n: usize = 0;
        for (self.meks) |m| {
            if (m.ready) n += 1;
        }
        return n;
    }

    /// Mark the mek called `name` as not ready. Returns false if no such mek.
    pub fn damage(self: *Self, name: []const u8) bool {
        for (&self.meks) |*m| {
            if (std.mem.eql(u8, m.name, name)) {
                m.ready = false;
                return true;
            }
        }
        return false;
    }

    /// The heaviest ready mek, or null if none is ready.
    pub fn heaviestReady(self: *const Self) ?*const Mek {
        var best: ?*const Mek = null;
        for (&self.meks) |*m| {
            if (!m.ready) continue;
            if (best == null or m.tons > best.?.tons) best = m;
        }
        return best;
    }
};

fn sampleLance() Lance {
    return .{
        .name = "Alpha",
        .meks = .{
            .{ .name = "Atlas", .tons = 100 },
            .{ .name = "Locust", .tons = 20 },
            .{ .name = "Marauder", .tons = 75 },
            .{ .name = "Shadow Hawk", .tons = 55 },
        },
    };
}

test "tonnage and readiness" {
    const l = sampleLance();
    try std.testing.expectEqual(@as(u32, 250), l.tonnage());
    try std.testing.expectEqual(@as(usize, 4), l.readyCount());
}

test "damage through a pointer" {
    var l = sampleLance();
    try std.testing.expect(l.damage("Atlas"));
    try std.testing.expect(!l.damage("Urbanmech"));
    try std.testing.expectEqual(@as(usize, 3), l.readyCount());
    try std.testing.expectEqual(@as(u32, 250), l.tonnage()); // tonnage unchanged
}

test "heaviest ready" {
    var l = sampleLance();
    try std.testing.expectEqualStrings("Atlas", l.heaviestReady().?.name);
    _ = l.damage("Atlas");
    try std.testing.expectEqualStrings("Marauder", l.heaviestReady().?.name);
    for (&l.meks) |*m| m.ready = false;
    try std.testing.expect(l.heaviestReady() == null);
}
