//! Chapter 17, exercise 2: errdefer keeps a failing constructor leak-free.
//! Run with:  zig test ex2_errdefer.zig
//! Goal: make every test pass without changing the tests. The testing
//! allocator fails the test if anything leaks.
const std = @import("std");

const Squad = struct {
    name: []u8,
    skills: []u8,

    /// Allocates a copy of `name` and a skills array. If `size` is 0 or
    /// more than 12, fails with error.BadSize, leaking nothing.
    fn create(a: std.mem.Allocator, name: []const u8, size: usize) !Squad {
        const name_copy = try a.dupe(u8, name);
        errdefer a.free(name_copy);

        if (size == 0 or size > 12) return error.BadSize;

        const skills = try a.alloc(u8, size);
        errdefer a.free(skills);
        @memset(skills, 4);

        return .{ .name = name_copy, .skills = skills };
    }

    fn deinit(self: *Squad, a: std.mem.Allocator) void {
        a.free(self.skills);
        a.free(self.name);
    }
};

test "good squad" {
    var s = try Squad.create(std.testing.allocator, "Alpha", 4);
    defer s.deinit(std.testing.allocator);
    try std.testing.expectEqualStrings("Alpha", s.name);
    try std.testing.expectEqual(@as(usize, 4), s.skills.len);
    try std.testing.expectEqual(@as(u8, 4), s.skills[3]);
}

test "bad size leaks nothing" {
    try std.testing.expectError(error.BadSize, Squad.create(std.testing.allocator, "Beta", 0));
    try std.testing.expectError(error.BadSize, Squad.create(std.testing.allocator, "Gamma", 13));
}
