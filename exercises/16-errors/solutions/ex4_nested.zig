//! Chapter 16, exercise 4: an error union around an optional (E!?T).
//! Run with:  zig test ex4_nested.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Command = union(enum) {
    hire: []const u8,
    fire: []const u8,
    advance: u32,
    quit,
};

const ParseError = error{ EmptyLine, MissingArgument, BadNumber };

/// Parse one line of the REPL.
///   error  -> the line was malformed
///   null   -> well-formed but not a verb we know
///   value  -> a command
fn parseCommand(line: []const u8) ParseError!?Command {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    const verb = it.next() orelse return error.EmptyLine;
    if (std.mem.eql(u8, verb, "quit")) return .quit;
    if (std.mem.eql(u8, verb, "hire")) return .{ .hire = it.next() orelse return error.MissingArgument };
    if (std.mem.eql(u8, verb, "fire")) return .{ .fire = it.next() orelse return error.MissingArgument };
    if (std.mem.eql(u8, verb, "advance")) {
        const arg = it.next() orelse return error.MissingArgument;
        const n = std.fmt.parseInt(u32, arg, 10) catch return error.BadNumber;
        return .{ .advance = n };
    }
    return null;
}

test "commands" {
    const h = (try parseCommand("hire Steiner")).?;
    try std.testing.expectEqualStrings("Steiner", h.hire);
    const adv = (try parseCommand("advance 7")).?;
    try std.testing.expectEqual(@as(u32, 7), adv.advance);
    try std.testing.expect((try parseCommand("quit")).? == .quit);
}

test "unknown verb is null, not an error" {
    try std.testing.expect((try parseCommand("dance wildly")) == null);
}

test "malformed lines are errors" {
    try std.testing.expectError(error.EmptyLine, parseCommand("   "));
    try std.testing.expectError(error.MissingArgument, parseCommand("hire"));
    try std.testing.expectError(error.BadNumber, parseCommand("advance soon"));
}
