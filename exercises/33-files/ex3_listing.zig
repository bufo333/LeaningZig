//! Chapter 33, exercise 3: list save files in a directory.
//! Run with:  zig test ex3_listing.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

/// Names of the regular files directly inside `sub_path` whose extension is
/// `ext` (for example ".zon"), sorted, copied into `gpa`.
pub fn listSaves(dir: std.Io.Dir, io: std.Io, gpa: std.mem.Allocator, sub_path: []const u8, ext: []const u8) ![][]u8 {
    // TODO: implement this function.
    @panic("TODO");
}

fn lessThan(_: void, a: []u8, b: []u8) bool {
    return std.mem.lessThan(u8, a, b);
}

pub fn freeNames(gpa: std.mem.Allocator, names: [][]u8) void {
    for (names) |n| gpa.free(n);
    gpa.free(names);
}

test "only .zon files, sorted" {
    const io = std.testing.io;
    const gpa = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.createDirPath(io, "saves/old");
    try tmp.dir.writeFile(io, .{ .sub_path = "saves/day-002.zon", .data = "" });
    try tmp.dir.writeFile(io, .{ .sub_path = "saves/day-001.zon", .data = "" });
    try tmp.dir.writeFile(io, .{ .sub_path = "saves/readme.txt", .data = "" });
    try tmp.dir.writeFile(io, .{ .sub_path = "saves/old/day-000.zon", .data = "" });
    const names = try listSaves(tmp.dir, io, gpa, "saves", ".zon");
    defer freeNames(gpa, names);
    try std.testing.expectEqual(@as(usize, 2), names.len);
    try std.testing.expectEqualStrings("day-001.zon", names[0]);
    try std.testing.expectEqualStrings("day-002.zon", names[1]);
}

test "missing directory is FileNotFound" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try std.testing.expectError(error.FileNotFound, listSaves(tmp.dir, std.testing.io, std.testing.allocator, "nope", ".zon"));
}
