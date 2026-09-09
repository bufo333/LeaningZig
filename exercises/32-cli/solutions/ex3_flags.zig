//! Chapter 32, exercise 3: a flag parser you can test.
//! Run with:  zig test ex3_flags.zig
//! Goal: make every test pass without changing the tests.
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
    var opts = Options{};
    var files: std.ArrayList([]const u8) = .empty;
    errdefer files.deinit(gpa);
    var i: usize = 0;
    var only_positional = false;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (only_positional or !std.mem.startsWith(u8, arg, "-")) {
            try files.append(gpa, arg);
        } else if (std.mem.eql(u8, arg, "--")) {
            only_positional = true;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
            opts.verbose = true;
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            return error.HelpRequested;
        } else if (std.mem.eql(u8, arg, "--days")) {
            i += 1;
            if (i >= args.len) return error.MissingValue;
            opts.days = std.fmt.parseInt(u32, args[i], 10) catch return error.BadNumber;
        } else if (std.mem.eql(u8, arg, "--name")) {
            i += 1;
            if (i >= args.len) return error.MissingValue;
            opts.name = args[i];
        } else if (std.mem.startsWith(u8, arg, "--name=")) {
            opts.name = arg["--name=".len..];
        } else {
            return error.UnknownFlag;
        }
    }
    opts.files = try files.toOwnedSlice(gpa);
    return opts;
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
