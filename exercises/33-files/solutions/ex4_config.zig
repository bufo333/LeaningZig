//! Chapter 33, exercise 4: a config file with a default, and a safe rewrite.
//! Run with:  zig test ex4_config.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

pub const Config = struct { seed: u64 = 3025, autosave: bool = true };

/// Load "config.zon" from `dir`. If the file does not exist, return the
/// defaults. Any other error (including a bad file) propagates.
pub fn load(dir: std.Io.Dir, io: std.Io, gpa: std.mem.Allocator) !Config {
    var buf: [256]u8 = undefined;
    const text = dir.readFile(io, "config.zon", &buf) catch |err| switch (err) {
        error.FileNotFound => return Config{},
        else => return err,
    };
    const z = try gpa.dupeZ(u8, text);
    defer gpa.free(z);
    return std.zon.parse.fromSlice(Config, gpa, z, null, .{});
}

/// Write "config.zon" atomically: serialize to "config.zon.tmp", then rename
/// over the real name, so a crash mid-write never leaves a half file.
pub fn store(dir: std.Io.Dir, io: std.Io, cfg: Config) !void {
    var file = try dir.createFile(io, "config.zon.tmp", .{});
    var buf: [256]u8 = undefined;
    var fw = file.writer(io, &buf);
    try std.zon.stringify.serialize(cfg, .{}, &fw.interface);
    try fw.interface.writeByte('\n');
    try fw.interface.flush();
    file.close(io);
    try dir.rename("config.zon.tmp", dir, "config.zon", io);
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
