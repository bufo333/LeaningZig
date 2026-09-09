//! Chapter 18, exercise 3: pointers to arrays, elements and many items.
//! Run with:  zig test ex3_arrays.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Double every element in place.
fn doubleAll(items: []u32) void {
    for (items) |*x| x.* *= 2;
}

/// Pointer to a fixed-size array: set every element to `v`.
fn fill4(arr: *[4]u8, v: u8) void {
    for (arr) |*x| x.* = v;
}

/// Pointer to the largest element, or null for an empty slice.
fn largest(items: []u32) ?*u32 {
    if (items.len == 0) return null;
    var best: *u32 = &items[0];
    for (items[1..]) |*x| if (x.* > best.*) {
        best = x;
    };
    return best;
}

/// A many-item pointer has no length, so the caller passes one.
fn sumMany(p: [*]const u32, n: usize) u32 {
    var total: u32 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) total += p[i];
    return total;
}

test "doubleAll" {
    var hp = [_]u32{ 1, 2, 3 };
    doubleAll(&hp); // *[3]u32 coerces to []u32
    try std.testing.expectEqualSlices(u32, &.{ 2, 4, 6 }, &hp);
}

test "fill4" {
    var buf: [4]u8 = undefined;
    fill4(&buf, 'x');
    try std.testing.expectEqualStrings("xxxx", &buf);
}

test "largest points into the slice" {
    var hp = [_]u32{ 5, 9, 2 };
    const p = largest(&hp).?;
    p.* = 0; // writing through the pointer changes the array
    try std.testing.expectEqualSlices(u32, &.{ 5, 0, 2 }, &hp);
    var none = [_]u32{};
    try std.testing.expect(largest(&none) == null);
}

test "sumMany" {
    const hp = [_]u32{ 1, 2, 3, 4 };
    const many: [*]const u32 = &hp;
    try std.testing.expectEqual(@as(u32, 10), sumMany(many, 4));
    try std.testing.expectEqual(@as(u32, 3), sumMany(many, 2));
}
