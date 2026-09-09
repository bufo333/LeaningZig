//! Chapter 33, exercise 4: a config file with a default, and a safe rewrite.
//! Run with:  zig test ex4_config.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Config = struct { seed: u64 = 3025, autosave: bool = true };

/// Load "config.zon" from `dir`. If the file does not exist, return the
/// defaults. Any other error (including a bad file) propagates.
pub fn load(dir: std.Io.Dir, io: std.Io, gpa: std.mem.Allocator) !Config {
    // TODO: implement this function.
    @panic("TODO");
}

/// Write "config.zon" atomically: serialize to "config.zon.tmp", then rename
/// over the real name, so a crash mid-write never leaves a half file.
pub fn store(dir: std.Io.Dir, io: std.Io, cfg: Config) !void {
    // TODO: implement this function.
    @panic("TODO");
}

test "defaults when absent" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const cfg = try load(tmp.dir, std.testing.io, std.testing.allocator);
    try std.testing.expectEqual(@as(u64, 3025), cfg.seed);
    try std.testing.expect(cfg.autosave);
}

test "store then load" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try store(tmp.dir, io, .{ .seed = 7, .autosave = false });
    const cfg = try load(tmp.dir, io, std.testing.allocator);
    try std.testing.expectEqual(@as(u64, 7), cfg.seed);
    try std.testing.expect(!cfg.autosave);
    try std.testing.expectError(error.FileNotFound, tmp.dir.access(io, "config.zon.tmp", .{}));
}

test "a corrupt file is an error, not a default" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(io, .{ .sub_path = "config.zon", .data = ".{ .seed = \"no\" }" });
    try std.testing.expectError(error.ParseZon, load(tmp.dir, io, std.testing.allocator));
}
