//! Chapter 13, exercise 4: a day-phase state machine (challenge).
//! Run with:  zig test ex4_phases.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// The phases of one campaign day, in order.
const Phase = enum(u8) {
    travel,
    supply,
    events,
    battle,
    finances,
    decisions,

    /// The next phase, or null after the last one.
    /// Hint: std.enums.values(Phase) is an array of every value in order.
    pub fn next(self: Phase) ?Phase {
        _ = self;
        // TODO
    }

    /// True when `self` happens before `other`.
    pub fn before(self: Phase, other: Phase) bool {
        _ = self;
        _ = other;
        // TODO
    }

    /// Human label: the tag name with the first letter upper-cased, into buf.
    pub fn label(self: Phase, buf: []u8) []const u8 {
        _ = self;
        _ = buf;
        // TODO
    }
};

/// Run every phase from `start` to the end, writing the names visited into `out`.
/// Returns how many phases ran.
fn runDay(start: Phase, out: []Phase) usize {
    _ = start;
    _ = out;
    // TODO: a while loop over an optional, advancing with next()
}

test "next walks in declaration order" {
    try std.testing.expectEqual(@as(?Phase, .supply), Phase.travel.next());
    try std.testing.expectEqual(@as(?Phase, .decisions), Phase.finances.next());
    try std.testing.expectEqual(@as(?Phase, null), Phase.decisions.next());
}

test "ordering" {
    try std.testing.expect(Phase.travel.before(.battle));
    try std.testing.expect(!Phase.battle.before(.travel));
    try std.testing.expect(!Phase.battle.before(.battle));
}

test "labels" {
    var buf: [16]u8 = undefined;
    try std.testing.expectEqualStrings("Finances", Phase.finances.label(&buf));
}

test "runDay" {
    var out: [8]Phase = undefined;
    try std.testing.expectEqual(@as(usize, 6), runDay(.travel, &out));
    try std.testing.expectEqual(Phase.travel, out[0]);
    try std.testing.expectEqual(Phase.decisions, out[5]);
    try std.testing.expectEqual(@as(usize, 2), runDay(.finances, &out));
    try std.testing.expectEqual(Phase.finances, out[0]);
}
