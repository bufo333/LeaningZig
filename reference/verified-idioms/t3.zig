const std = @import("std");
const Shape = union(enum) { circle: f64, square: f64,
    fn area(s: Shape) f64 { return switch (s) { .circle => |r| std.math.pi * r * r, .square => |w| w * w }; } };
fn Stack(comptime T: type) type {
    return struct {
        items: std.ArrayList(T) = .empty,
        const Self = @This();
        fn push(self: *Self, a: std.mem.Allocator, v: T) !void { try self.items.append(a, v); }
        fn pop(self: *Self) ?T { return self.items.pop(); }
        fn deinit(self: *Self, a: std.mem.Allocator) void { self.items.deinit(a); }
    };
}
test "generic stack + union" {
    var s = Stack(u8){};
    defer s.deinit(std.testing.allocator);
    try s.push(std.testing.allocator, 3);
    try std.testing.expectEqual(@as(?u8, 3), s.pop());
    try std.testing.expectEqual(@as(?u8, null), s.pop());
    const sh: Shape = .{ .square = 2 };
    try std.testing.expectEqual(@as(f64, 4), sh.area());
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const p = try gpa.allocator().alloc(u8, 4);
    defer gpa.allocator().free(p);
    @memset(p, 'x');
    try std.testing.expectEqualStrings("xxxx", p);
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const s2 = try std.fmt.allocPrint(arena.allocator(), "{s}", .{"ok"});
    try std.testing.expectEqualStrings("ok", s2);
    const T = struct { a: u8, b: []const u8 };
    inline for (@typeInfo(T).@"struct".fields) |f| std.debug.print("{s} ", .{f.name});
    const E = enum { x, y };
    try std.testing.expectEqualStrings("y", @tagName(E.y));
    const v: @Vector(4, i32) = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(i32, 10), @reduce(.Add, v));
    var buf: [8]u8 = undefined;
    var fbs = std.Io.Writer.fixed(&buf);
    try fbs.print("{d}", .{123});
    try std.testing.expectEqualStrings("123", fbs.buffered());
    const t = std.mem.trim(u8, "  hi ", " ");
    try std.testing.expectEqualStrings("hi", t);
    const p2: packed struct(u8) { lo: u4, hi: u4 } = @bitCast(@as(u8, 0xAB));
    try std.testing.expectEqual(@as(u4, 0xB), p2.lo);
    const err_union: anyerror!u8 = error.Boom;
    try std.testing.expectError(error.Boom, err_union);
    var th = try std.Thread.spawn(.{}, struct { fn f(x: *u32) void { x.* += 1; } }.f, .{&counter});
    th.join();
    try std.testing.expectEqual(@as(u32, 1), counter);
}
var counter: u32 = 0;
