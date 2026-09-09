//! Chapter 14, exercise 3: commands as a tagged union.
//! Run with:  zig test ex3_commands.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const Command = union(enum) {
    advance_day,
    advance_days: u32,
    hire: struct { name: []const u8, salary: i64 },
    fire: u32, // staff index
    deposit: i64,
};

const Error = error{ NoSuchPerson, InsufficientFunds, TooManyStaff };

const State = struct {
    day: u32 = 1,
    funds: i64 = 10_000,
    staff: [4]?[]const u8 = .{ null, null, null, null },

    fn headcount(self: State) usize {
        var n: usize = 0;
        for (self.staff) |s| {
            if (s != null) n += 1;
        }
        return n;
    }
};

/// Apply one command. hire: refuse if salary > funds (InsufficientFunds),
/// put the name in the first null slot and subtract the salary, or
/// TooManyStaff if no slot is free. fire: NoSuchPerson for a bad or empty index.
fn execute(s: *State, cmd: Command) Error!void {
    _ = s;
    _ = cmd;
    // TODO: one exhaustive switch
}

/// Parse an optional token as a number; a missing token is an error too.
fn num(comptime T: type, tok: ?[]const u8) !T {
    return std.fmt.parseInt(T, tok orelse "", 10);
}

/// Parse one line of text into a command, or null for an unknown verb.
/// Verbs: "day", "days N", "hire NAME SALARY", "fire N", "deposit N".
/// A missing or bad number should come out as parseInt's error.
fn parse(line: []const u8) !?Command {
    _ = line;
    // TODO: tokenizeScalar, compare the verb, use num() for the numbers
}

test "execute" {
    var s = State{};
    try execute(&s, .{ .hire = .{ .name = "Kai", .salary = 1_500 } });
    try execute(&s, .{ .advance_days = 10 });
    try std.testing.expectEqual(@as(u32, 11), s.day);
    try std.testing.expectEqual(@as(i64, 8_500), s.funds);
    try std.testing.expectEqual(@as(usize, 1), s.headcount());
    try execute(&s, .{ .fire = 0 });
    try std.testing.expectEqual(@as(usize, 0), s.headcount());
}

test "errors" {
    var s = State{ .funds = 100 };
    const kai: Command = .{ .hire = .{ .name = "Kai", .salary = 1_500 } };
    try std.testing.expectError(error.InsufficientFunds, execute(&s, kai));
    try std.testing.expectError(error.NoSuchPerson, execute(&s, .{ .fire = 2 }));
    s.funds = 1_000_000;
    for ([_][]const u8{ "a", "b", "c", "d" }) |n| {
        try execute(&s, .{ .hire = .{ .name = n, .salary = 1 } });
    }
    const one_more: Command = .{ .hire = .{ .name = "e", .salary = 1 } };
    try std.testing.expectError(error.TooManyStaff, execute(&s, one_more));
}

test "parse" {
    try std.testing.expectEqual(@as(?Command, .advance_day), try parse("day"));
    try std.testing.expectEqual(@as(?Command, .{ .advance_days = 30 }), try parse("days 30"));
    try std.testing.expectEqual(@as(?Command, null), try parse("dance"));
    try std.testing.expectError(error.InvalidCharacter, parse("days thirty"));
    const h = (try parse("hire Kai 1500")).?;
    try std.testing.expectEqualStrings("Kai", h.hire.name);
    try std.testing.expectEqual(@as(i64, 1500), h.hire.salary);
}

test "a script" {
    var s = State{};
    const lines = [_][]const u8{
        "hire Kai 1500", "hire Nat 800", "deposit 5000", "days 30", "fire 1", "day",
    };
    for (lines) |l| {
        const cmd = (try parse(l)) orelse continue;
        try execute(&s, cmd);
    }
    try std.testing.expectEqual(@as(u32, 32), s.day);
    try std.testing.expectEqual(@as(i64, 12_700), s.funds);
    try std.testing.expectEqual(@as(usize, 1), s.headcount());
}
