//! Chapter 33, exercise 2: count lines, words and bytes of a file.
//! Run with:  zig test ex2_wordcount.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Counts = struct { lines: u32 = 0, words: u32 = 0, bytes: u64 = 0 };

/// Stream the file through a small buffer; never load it whole.
pub fn count(dir: std.Io.Dir, io: std.Io, path: []const u8) !Counts {
    // TODO: implement this function.
    @panic("TODO");
}

test "counts" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(io, .{ .sub_path = "t.txt", .data = "alpha beta\ngamma\n\ndelta epsilon zeta\n" });
    const c = try count(tmp.dir, io, "t.txt");
    try std.testing.expectEqual(@as(u32, 4), c.lines);
    try std.testing.expectEqual(@as(u32, 6), c.words);
    try std.testing.expectEqual(@as(u64, 37), c.bytes);
}

test "empty file" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(io, .{ .sub_path = "e.txt", .data = "" });
    try std.testing.expectEqual(Counts{}, try count(tmp.dir, io, "e.txt"));
}

test "a line longer than the buffer is reported" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const long = "x" ** 100 ++ "\n";
    try tmp.dir.writeFile(io, .{ .sub_path = "l.txt", .data = long });
    try std.testing.expectError(error.LineTooLong, count(tmp.dir, io, "l.txt"));
}
