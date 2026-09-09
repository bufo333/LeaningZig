//! Chapter 26, exercise 4: a matrix type with compile-time dimensions.
//! Run with:  zig test ex4_matrix.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

fn Matrix(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    return struct {
        const Self = @This();
        pub const Rows = rows;
        pub const Cols = cols;

        data: [rows][cols]T = @splat(@splat(0)),

        pub fn identity() Self {
            // TODO
        }

        pub fn at(self: Self, r: usize, c: usize) T {
            return self.data[r][c];
        }

        pub fn set(self: *Self, r: usize, c: usize, v: T) void {
            self.data[r][c] = v;
        }

        /// Multiply by a matrix whose row count equals our column count.
        /// The result's shape is known at compile time; a mismatch is a compile error.
        pub fn mul(self: Self, other: anytype) Matrix(T, rows, @TypeOf(other).Cols) {
            _ = self;
            _ = other;
            // TODO
        }
    };
}

test "identity" {
    const I = Matrix(i32, 2, 2).identity();
    try std.testing.expectEqual(@as(i32, 1), I.at(0, 0));
    try std.testing.expectEqual(@as(i32, 0), I.at(0, 1));
}

test "multiply 2x3 by 3x2 gives 2x2" {
    var a: Matrix(i32, 2, 3) = .{};
    var b: Matrix(i32, 3, 2) = .{};
    // a = [1 2 3; 4 5 6], b = [7 8; 9 10; 11 12]
    var v: i32 = 1;
    for (0..2) |r| for (0..3) |c| {
        a.set(r, c, v);
        v += 1;
    };
    for (0..3) |r| for (0..2) |c| {
        b.set(r, c, v);
        v += 1;
    };
    const p = a.mul(b);
    try std.testing.expect(@TypeOf(p) == Matrix(i32, 2, 2));
    try std.testing.expectEqual(@as(i32, 58), p.at(0, 0));
    try std.testing.expectEqual(@as(i32, 64), p.at(0, 1));
    try std.testing.expectEqual(@as(i32, 139), p.at(1, 0));
    try std.testing.expectEqual(@as(i32, 154), p.at(1, 1));
}

test "identity leaves a matrix unchanged" {
    var m: Matrix(f64, 2, 2) = .{};
    m.set(0, 1, 2.5);
    m.set(1, 0, -1);
    const same = m.mul(Matrix(f64, 2, 2).identity());
    try std.testing.expectEqual(@as(f64, 2.5), same.at(0, 1));
    try std.testing.expectEqual(@as(f64, -1), same.at(1, 0));
}
