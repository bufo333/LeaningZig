//! Chapter 19, exercise 2: one struct on the heap with create/destroy.
//! Run with:  zig test ex2_create.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Pilot = struct {
    name: []u8,
    skill: u8,

    /// Heap-allocate a Pilot that owns a copy of `name`.
    fn create(a: std.mem.Allocator, name: []const u8, skill: u8) !*Pilot {
        const p = try a.create(Pilot);
        errdefer a.destroy(p);
        p.* = .{ .name = try a.dupe(u8, name), .skill = skill };
        return p;
    }

    /// Free the name, then the struct itself.
    fn destroy(self: *Pilot, a: std.mem.Allocator) void {
        a.free(self.name);
        a.destroy(self);
    }
};

test "create and destroy" {
    const a = std.testing.allocator;
    const p = try Pilot.create(a, "Ada", 4);
    defer p.destroy(a);
    try std.testing.expectEqualStrings("Ada", p.name);
    p.skill -= 1;
    try std.testing.expectEqual(@as(u8, 3), p.skill);
}

test "a failing allocator leaks nothing" {
    // failing_allocator fails the 2nd allocation: the dupe. The errdefer
    // must destroy the already-created struct.
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 1 });
    try std.testing.expectError(error.OutOfMemory, Pilot.create(failing.allocator(), "Bo", 5));
}
