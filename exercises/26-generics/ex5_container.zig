//! Chapter 26, exercise 5: a generic container with an allocator, plus duck typing.
//! Run with:  zig test ex5_container.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const Item = T;

        items: std.ArrayList(T) = .empty,

        pub fn deinit(self: *Self, gpa: std.mem.Allocator) void {
            self.items.deinit(gpa);
        }

        pub fn push(self: *Self, gpa: std.mem.Allocator, v: T) !void {
            try self.items.append(gpa, v);
        }

        pub fn pushAll(self: *Self, gpa: std.mem.Allocator, vs: []const T) !void {
            _ = self;
            _ = gpa;
            _ = vs;
            // TODO
        }

        pub fn pop(self: *Self) ?T {
            return self.items.pop();
        }

        /// A new stack whose items are f(item) for each item, in the same order.
        /// The result type comes from f's return type.
        pub fn map(self: Self, gpa: std.mem.Allocator, comptime f: anytype) !Stack(@TypeOf(f(@as(T, undefined)))) {
            _ = self;
            _ = gpa;
            // TODO
        }

        pub fn slice(self: Self) []const T {
            return self.items.items;
        }
    };
}

/// Works on anything that has a `slice()` method returning a slice, or is a slice itself.
fn total(container: anytype) i64 {
    _ = container;
    // TODO
}

fn square(x: u32) u64 {
    return @as(u64, x) * x;
}

test "push, pushAll, pop" {
    const a = std.testing.allocator;
    var s: Stack(u32) = .{};
    defer s.deinit(a);
    try s.push(a, 1);
    try s.pushAll(a, &.{ 2, 3 });
    try std.testing.expectEqual(@as(?u32, 3), s.pop());
    try std.testing.expectEqual(@as(usize, 2), s.slice().len);
    try std.testing.expect(Stack(u32).Item == u32);
}

test "map to a different element type" {
    const a = std.testing.allocator;
    var s: Stack(u32) = .{};
    defer s.deinit(a);
    try s.pushAll(a, &.{ 2, 3, 4 });
    var sq = try s.map(a, square);
    defer sq.deinit(a);
    try std.testing.expect(@TypeOf(sq) == Stack(u64));
    try std.testing.expectEqualSlices(u64, &.{ 4, 9, 16 }, sq.slice());
}

test "total is duck typed" {
    const a = std.testing.allocator;
    var s: Stack(u32) = .{};
    defer s.deinit(a);
    try s.pushAll(a, &.{ 10, 20 });
    try std.testing.expectEqual(@as(i64, 30), total(s));
    try std.testing.expectEqual(@as(i64, 6), total(@as([]const i32, &.{ 1, 2, 3 })));
    try std.testing.expectEqual(@as(i64, 3), total([_]u8{ 1, 2 }));
}
