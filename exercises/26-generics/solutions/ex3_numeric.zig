//! Chapter 26, exercise 3: generic functions with anytype and constraints.
//! Run with:  zig test ex3_numeric.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// The element type of an array, slice, or pointer to array.
fn Elem(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .array => |a| a.child,
        .pointer => |p| switch (p.size) {
            .slice => p.child,
            .one => Elem(p.child), // *[N]T -> T
            else => @compileError("unsupported pointer type " ++ @typeName(T)),
        },
        else => @compileError("sum needs an array or slice, got " ++ @typeName(T)),
    };
}

/// Sum of any array or slice, in the element's own type.
fn sum(items: anytype) Elem(@TypeOf(items)) {
    var total: Elem(@TypeOf(items)) = 0;
    for (items) |x| total += x;
    return total;
}

/// Mean of a slice; T must be a float type, checked at compile time.
fn average(comptime T: type, xs: []const T) T {
    if (@typeInfo(T) != .float) @compileError("average needs a float type, got " ++ @typeName(T));
    if (xs.len == 0) return 0;
    return sum(xs) / @as(T, @floatFromInt(xs.len));
}

/// The largest of any number of arguments passed as a tuple.
fn maxOfAll(args: anytype) @TypeOf(args[0]) {
    var best = args[0];
    inline for (args) |a| {
        if (a > best) best = a;
    }
    return best;
}

test "sum keeps the element type" {
    const arr = [_]u8{ 100, 100, 50 };
    try std.testing.expectEqual(@as(u8, 250), sum(arr));
    try std.testing.expectEqual(@as(u8, 250), sum(&arr));
    const sl: []const i64 = &.{ -5, 10 };
    try std.testing.expectEqual(@as(i64, 5), sum(sl));
    try std.testing.expect(@TypeOf(sum(sl)) == i64);
}

test "average" {
    try std.testing.expectEqual(@as(f64, 2.5), average(f64, &.{ 1, 2, 3, 4 }));
    try std.testing.expectEqual(@as(f32, 0), average(f32, &.{}));
}

test "maxOfAll" {
    try std.testing.expectEqual(@as(i32, 9), maxOfAll(.{ @as(i32, 3), 9, -2, 7 }));
    try std.testing.expectEqual(@as(f64, 2.5), maxOfAll(.{ @as(f64, 1), 2.5 }));
}
