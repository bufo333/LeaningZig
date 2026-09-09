//! Chapter 24, exercise 1: chop a command line into a verb and arguments.
//! Run with:  zig test ex1_command.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Verb = enum { hire, fire, transfer, unknown };
const Command = struct { verb: Verb, arg_count: usize, first_arg: ?[]const u8 };

/// "  hire   pilot Kell " -> verb hire, 2 args, first arg "pilot".
/// The verb is matched case-insensitively.
fn parseCommand(line: []const u8) Command {
    var it = std.mem.tokenizeAny(u8, line, " \t");
    const word = it.next() orelse return .{ .verb = .unknown, .arg_count = 0, .first_arg = null };
    var lower_buf: [16]u8 = undefined;
    const verb: Verb = if (word.len > lower_buf.len)
        .unknown
    else
        std.meta.stringToEnum(Verb, std.ascii.lowerString(&lower_buf, word)) orelse .unknown;
    const first = it.next();
    var count: usize = if (first != null) 1 else 0;
    while (it.next()) |_| count += 1;
    return .{ .verb = verb, .arg_count = count, .first_arg = first };
}

test "hire" {
    const c = parseCommand("  hire   pilot Kell ");
    try std.testing.expectEqual(Verb.hire, c.verb);
    try std.testing.expectEqual(@as(usize, 2), c.arg_count);
    try std.testing.expectEqualStrings("pilot", c.first_arg.?);
}

test "case and tabs" {
    const c = parseCommand("TRANSFER\toutfit\thq\t5000");
    try std.testing.expectEqual(Verb.transfer, c.verb);
    try std.testing.expectEqual(@as(usize, 3), c.arg_count);
}

test "unknown and empty" {
    try std.testing.expectEqual(Verb.unknown, parseCommand("dance").verb);
    const e = parseCommand("   ");
    try std.testing.expectEqual(Verb.unknown, e.verb);
    try std.testing.expectEqual(@as(usize, 0), e.arg_count);
    try std.testing.expect(e.first_arg == null);
}
