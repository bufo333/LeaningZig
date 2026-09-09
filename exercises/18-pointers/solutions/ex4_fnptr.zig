//! Chapter 18, exercise 4: a dispatch table of function pointers.
//! Run with:  zig test ex4_fnptr.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Op = *const fn (i32) i32;

fn double(x: i32) i32 {
    return x * 2;
}
fn negate(x: i32) i32 {
    return -x;
}
fn square(x: i32) i32 {
    return x * x;
}

const Entry = struct { name: []const u8, op: Op };

const table = [_]Entry{
    .{ .name = "double", .op = double },
    .{ .name = "negate", .op = negate },
    .{ .name = "square", .op = square },
};

/// Look up the operation by name, or null if unknown.
fn lookup(name: []const u8) ?Op {
    for (table) |e| if (std.mem.eql(u8, e.name, name)) return e.op;
    return null;
}

/// Apply the named operation, or return null if the name is unknown.
fn apply(name: []const u8, x: i32) ?i32 {
    const op = lookup(name) orelse return null;
    return op(x);
}

/// Run every op in `ops` left to right, starting from `start`.
fn pipeline(ops: []const Op, start: i32) i32 {
    var v = start;
    for (ops) |op| v = op(v);
    return v;
}

test "apply by name" {
    try std.testing.expectEqual(@as(?i32, 10), apply("double", 5));
    try std.testing.expectEqual(@as(?i32, -5), apply("negate", 5));
    try std.testing.expectEqual(@as(?i32, 25), apply("square", 5));
    try std.testing.expectEqual(@as(?i32, null), apply("cube", 5));
}

test "pipeline" {
    const ops = [_]Op{ double, square, negate };
    try std.testing.expectEqual(@as(i32, -36), pipeline(&ops, 3));
    try std.testing.expectEqual(@as(i32, 7), pipeline(&.{}, 7));
}
