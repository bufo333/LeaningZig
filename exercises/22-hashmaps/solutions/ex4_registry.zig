//! Chapter 22, exercise 4: an ID -> entity registry, like GameState.people.
//! Run with:  zig test ex4_registry.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const PersonId = enum(u32) { _ };
const Status = enum { active, wounded, kia };
const Person = struct { name: []const u8, status: Status = .active, missions: u32 = 0 };

const Registry = struct {
    people: std.AutoArrayHashMapUnmanaged(PersonId, Person) = .empty,
    next: u32 = 1,

    fn deinit(self: *Registry, gpa: std.mem.Allocator) void {
        self.people.deinit(gpa);
    }

    fn hire(self: *Registry, gpa: std.mem.Allocator, name: []const u8) !PersonId {
        const id: PersonId = @enumFromInt(self.next);
        self.next += 1;
        try self.people.putNoClobber(gpa, id, .{ .name = name });
        return id;
    }

    fn person(self: *Registry, id: PersonId) ?*Person {
        return self.people.getPtr(id);
    }

    /// Every active person flies one mission. Returns how many flew.
    fn mission(self: *Registry) u32 {
        var flew: u32 = 0;
        for (self.people.values()) |*p| {
            if (p.status != .active) continue;
            p.missions += 1;
            flew += 1;
        }
        return flew;
    }

    /// Remove everyone with status kia, keeping the order of the rest.
    /// Returns how many were removed.
    fn bury(self: *Registry) u32 {
        var removed: u32 = 0;
        var i: usize = 0;
        while (i < self.people.count()) {
            if (self.people.values()[i].status == .kia) {
                self.people.orderedRemoveAt(i);
                removed += 1;
            } else i += 1;
        }
        return removed;
    }
};

test "hire, look up, mutate" {
    const a = std.testing.allocator;
    var r: Registry = .{};
    defer r.deinit(a);
    const kell = try r.hire(a, "Kell");
    const nat = try r.hire(a, "Natasha");
    try std.testing.expect(r.person(kell) != null);
    try std.testing.expect(r.person(@enumFromInt(999)) == null);
    r.person(nat).?.status = .wounded;
    try std.testing.expectEqual(@as(u32, 1), r.mission());
    try std.testing.expectEqual(@as(u32, 1), r.person(kell).?.missions);
    try std.testing.expectEqual(@as(u32, 0), r.person(nat).?.missions);
}

test "bury keeps order and ids stay valid" {
    const a = std.testing.allocator;
    var r: Registry = .{};
    defer r.deinit(a);
    const p1 = try r.hire(a, "one");
    const p2 = try r.hire(a, "two");
    const p3 = try r.hire(a, "three");
    const p4 = try r.hire(a, "four");
    r.person(p1).?.status = .kia;
    r.person(p3).?.status = .kia;
    try std.testing.expectEqual(@as(u32, 2), r.bury());
    try std.testing.expectEqual(@as(usize, 2), r.people.count());
    try std.testing.expectEqualStrings("two", r.people.values()[0].name);
    try std.testing.expectEqualStrings("four", r.people.values()[1].name);
    try std.testing.expect(r.person(p2) != null);
    try std.testing.expect(r.person(p4) != null);
    try std.testing.expect(r.person(p1) == null);
}
