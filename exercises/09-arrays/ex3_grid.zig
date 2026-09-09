//! Chapter 09, exercise 3: a hex-less battle grid.
//! Run with:  zig test ex3_grid.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const rows = 4;
const cols = 6;
const Grid = [rows][cols]u8;

/// A grid full of '.' characters. Hint: `**` repetition works on rows too.
fn emptyGrid() Grid {
    // TODO
}

/// Place marker `m` at (r, c). Out-of-range coordinates are a bug; let Zig panic.
fn place(g: *Grid, r: usize, c: usize, m: u8) void {
    _ = g;
    _ = r;
    _ = c;
    _ = m;
    // TODO
}

/// Count how many cells hold marker `m`.
fn count(g: Grid, m: u8) usize {
    _ = g;
    _ = m;
    // TODO
}

/// Write row `r` into `buf` and return it as text (for printing).
fn rowText(g: Grid, r: usize, buf: *[cols]u8) []const u8 {
    _ = g;
    _ = r;
    _ = buf;
    // TODO
}

test "empty grid is all dots" {
    const g = emptyGrid();
    try std.testing.expectEqual(@as(usize, rows * cols), count(g, '.'));
    try std.testing.expectEqual(@as(usize, 0), count(g, 'M'));
}

test "placing markers" {
    var g = emptyGrid();
    place(&g, 0, 0, 'M');
    place(&g, 3, 5, 'M');
    place(&g, 1, 2, 'T');
    try std.testing.expectEqual(@as(usize, 2), count(g, 'M'));
    try std.testing.expectEqual(@as(usize, 1), count(g, 'T'));
    try std.testing.expectEqual(@as(usize, rows * cols - 3), count(g, '.'));
}

test "row as text" {
    var g = emptyGrid();
    place(&g, 2, 1, 'M');
    var buf: [cols]u8 = undefined;
    try std.testing.expectEqualStrings(".M....", rowText(g, 2, &buf));
    try std.testing.expectEqualStrings("......", rowText(g, 0, &buf));
}
