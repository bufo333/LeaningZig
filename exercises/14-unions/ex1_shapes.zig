//! Chapter 14, exercise 1: a tagged union with methods.
//! Run with:  zig test ex1_shapes.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const Shape = union(enum) {
    circle: f64, // radius
    rect: struct { w: f64, h: f64 },
    square: f64, // side
    point,

    pub fn area(self: Shape) f64 {
        _ = self;
        // TODO: switch with |payload| captures
    }

    pub fn perimeter(self: Shape) f64 {
        _ = self;
        // TODO
    }

    /// Scale every dimension by k, in place. Hint: switch (self.*) with |*r|.
    pub fn scale(self: *Shape, k: f64) void {
        _ = self;
        _ = k;
        // TODO
    }

    /// A rect whose sides are equal is really a square; normalise it.
    pub fn simplify(self: Shape) Shape {
        _ = self;
        // TODO
    }
};

test "area and perimeter" {
    try std.testing.expectEqual(@as(f64, 6), (Shape{ .rect = .{ .w = 2, .h = 3 } }).area());
    try std.testing.expectEqual(@as(f64, 10), (Shape{ .rect = .{ .w = 2, .h = 3 } }).perimeter());
    try std.testing.expectEqual(@as(f64, 9), (Shape{ .square = 3 }).area());
    try std.testing.expectEqual(@as(f64, 0), (Shape{ .point = {} }).area());
    try std.testing.expectApproxEqAbs(@as(f64, 3.14159), (Shape{ .circle = 1 }).area(), 0.001);
}

test "scale in place" {
    var s = Shape{ .rect = .{ .w = 2, .h = 3 } };
    s.scale(2);
    try std.testing.expectEqual(@as(f64, 24), s.area());
    var p: Shape = .point;
    p.scale(100);
    try std.testing.expect(p == .point);
}

test "simplify" {
    const sq = (Shape{ .rect = .{ .w = 2, .h = 2 } }).simplify();
    try std.testing.expect(sq == .square);
    try std.testing.expectEqual(@as(f64, 2), sq.square);
    const r = (Shape{ .rect = .{ .w = 2, .h = 3 } }).simplify();
    try std.testing.expect(r == .rect);
}
