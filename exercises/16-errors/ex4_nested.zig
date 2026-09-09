//! Chapter 16, exercise 4: an error union around an optional (E!?T).
//! Run with:  zig test ex4_nested.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
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
    // TODO: implement
    @panic("TODO");
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
