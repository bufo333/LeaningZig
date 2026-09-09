//! Chapter 16, exercise 3: merging error sets, anyerror and @errorName.
//! Run with:  zig test ex3_merge.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const FileError = error{ NotFound, PermissionDenied };
const FormatError = error{ BadSyntax, TooLong };

/// Everything `load` can fail with: both sets merged, plus OutOfMemory.
const LoadError = FileError || FormatError || std.mem.Allocator.Error;

/// Pretend loader. Returns a copy of `name` (caller frees) or an error:
///   ""        -> NotFound
///   "locked"  -> PermissionDenied
///   starts '!' -> BadSyntax
///   > 8 chars -> TooLong
fn load(a: std.mem.Allocator, name: []const u8) LoadError![]u8 {
    if (name.len == 0) return error.NotFound;
    if (std.mem.eql(u8, name, "locked")) return error.PermissionDenied;
    if (name[0] == '!') return error.BadSyntax;
    if (name.len > 8) return error.TooLong;
    return a.dupe(u8, name);
}

/// A message for any error at all. Unknown ones fall back to @errorName.
fn errorText(err: anyerror) []const u8 {
    return switch (err) {
        error.NotFound => "no such save",
        error.PermissionDenied => "that save is locked",
        error.OutOfMemory => "out of memory",
        else => @errorName(err),
    };
}

test "load ok" {
    const s = try load(std.testing.allocator, "save1");
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings("save1", s);
}

test "load errors" {
    const a = std.testing.allocator;
    try std.testing.expectError(error.NotFound, load(a, ""));
    try std.testing.expectError(error.PermissionDenied, load(a, "locked"));
    try std.testing.expectError(error.BadSyntax, load(a, "!x"));
    try std.testing.expectError(error.TooLong, load(a, "far_too_long"));
}

test "errorText" {
    try std.testing.expectEqualStrings("no such save", errorText(error.NotFound));
    try std.testing.expectEqualStrings("TooLong", errorText(error.TooLong));
    try std.testing.expectEqualStrings("Whatever", errorText(error.Whatever));
}
