//! Chapter 28, exercise 2: parse ZON at run time with std.zon.parse.
//! Run with:  zig test ex2_runtime.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

pub const Difficulty = enum { easy, normal, hard };

pub const Config = struct {
    seed: u64 = 3025,
    difficulty: Difficulty = .normal,
    autosave: bool = true,
    company_name: []const u8 = "Unnamed Company",
};

/// Parse `source` into a Config. Strings inside the result live in `arena`,
/// so the caller frees everything by resetting the arena. On a parse error,
/// print the diagnostics to stderr and return error.ParseZon.
pub fn load(arena: std.mem.Allocator, source: [:0]const u8) !Config {
    var diag: std.zon.parse.Diagnostics = .{};
    defer diag.deinit(arena);
    return std.zon.parse.fromSliceAlloc(Config, arena, source, &diag, .{}) catch |err| {
        std.debug.print("config error: {f}", .{diag});
        return err;
    };
}

test "full config" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const cfg = try load(arena.allocator(),
        \\.{ .seed = 42, .difficulty = .hard, .autosave = false, .company_name = "Kell Hounds" }
    );
    try std.testing.expectEqual(@as(u64, 42), cfg.seed);
    try std.testing.expectEqual(Difficulty.hard, cfg.difficulty);
    try std.testing.expect(!cfg.autosave);
    try std.testing.expectEqualStrings("Kell Hounds", cfg.company_name);
}

test "defaults apply to missing fields" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const cfg = try load(arena.allocator(), ".{ .seed = 7 }");
    try std.testing.expectEqual(@as(u64, 7), cfg.seed);
    try std.testing.expectEqual(Difficulty.normal, cfg.difficulty);
    try std.testing.expectEqualStrings("Unnamed Company", cfg.company_name);
}

test "bad enum literal is a parse error" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    try std.testing.expectError(error.ParseZon, load(arena.allocator(), ".{ .difficulty = .brutal }"));
}

test "unknown field is a parse error" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    try std.testing.expectError(error.ParseZon, load(arena.allocator(), ".{ .sead = 1 }"));
}
