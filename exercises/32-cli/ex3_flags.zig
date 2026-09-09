//! Chapter 32, exercise 3: a flag parser you can test.
//! Run with:  zig test ex3_flags.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Options = struct {
    verbose: bool = false,
    days: u32 = 1,
    name: []const u8 = "campaign",
    /// Positional arguments, in order.
    files: []const []const u8 = &.{},
};

pub const ParseError = error{ MissingValue, BadNumber, UnknownFlag, HelpRequested };

/// Parse `args` (WITHOUT the program name). Positionals are copied into a
/// slice allocated from `gpa`; the caller frees `options.files`.
/// Supported: -v / --verbose, --days N, --name NAME, --name=NAME, -h / --help.
/// Everything after a bare "--" is positional even if it starts with "-".
pub fn parse(gpa: std.mem.Allocator, args: []const []const u8) (ParseError || std.mem.Allocator.Error)!Options {
    // TODO: implement this function.
    @panic("TODO");
}

test "flags and positionals" {
    const gpa = std.testing.allocator;
    const o = try parse(gpa, &.{ "-v", "--days", "30", "--name=Kell", "a.txt", "b.txt" });
    defer gpa.free(o.files);
    try std.testing.expect(o.verbose);
    try std.testing.expectEqual(@as(u32, 30), o.days);
    try std.testing.expectEqualStrings("Kell", o.name);
    try std.testing.expectEqual(@as(usize, 2), o.files.len);
    try std.testing.expectEqualStrings("b.txt", o.files[1]);
}

test "defaults" {
    const gpa = std.testing.allocator;
    const o = try parse(gpa, &.{});
    defer gpa.free(o.files);
    try std.testing.expect(!o.verbose);
    try std.testing.expectEqual(@as(u32, 1), o.days);
    try std.testing.expectEqualStrings("campaign", o.name);
    try std.testing.expectEqual(@as(usize, 0), o.files.len);
}

test "separate --name value and the -- separator" {
    const gpa = std.testing.allocator;
    const o = try parse(gpa, &.{ "--name", "Ana", "--", "-not-a-flag" });
    defer gpa.free(o.files);
    try std.testing.expectEqualStrings("Ana", o.name);
    try std.testing.expectEqualStrings("-not-a-flag", o.files[0]);
}

test "errors" {
    const gpa = std.testing.allocator;
    try std.testing.expectError(error.MissingValue, parse(gpa, &.{"--days"}));
    try std.testing.expectError(error.BadNumber, parse(gpa, &.{ "--days", "soon" }));
    try std.testing.expectError(error.UnknownFlag, parse(gpa, &.{"--bogus"}));
    try std.testing.expectError(error.HelpRequested, parse(gpa, &.{ "a", "-h" }));
}
