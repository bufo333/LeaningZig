//! Chapter 13, exercise 3: typed IDs with non-exhaustive enums.
//! Run with:  zig test ex3_ids.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

// TODO: declare PersonId and UnitId exactly as IRON LEDGER does:
// a non-exhaustive enum over u32 with a single named value `none = 0`.

/// Hands out fresh PersonIds, starting at 1.
const IdGen = struct {
    next: u32 = 1,

    pub fn newPerson(self: *IdGen) PersonId {
        _ = self;
        // TODO
    }
};

/// A pilot may or may not be assigned to a unit.
const Pilot = struct {
    id: PersonId,
    unit: UnitId = .none,

    pub fn isAssigned(self: Pilot) bool {
        _ = self;
        // TODO
    }
};

/// Parse text like "7" into a PersonId. "0" or garbage is null.
/// Hint: std.fmt.parseInt(u32, s, 10) catch return null;
fn parsePersonId(s: []const u8) ?PersonId {
    _ = s;
    // TODO
}

test "ids are distinct values" {
    var gen = IdGen{};
    const a = gen.newPerson();
    const b = gen.newPerson();
    try std.testing.expect(a != b);
    try std.testing.expect(a != .none);
    try std.testing.expectEqual(@as(u32, 1), @intFromEnum(a));
    try std.testing.expectEqual(@as(u32, 2), @intFromEnum(b));
}

test "assignment uses .none as absent" {
    var gen = IdGen{};
    var p = Pilot{ .id = gen.newPerson() };
    try std.testing.expect(!p.isAssigned());
    p.unit = @enumFromInt(42);
    try std.testing.expect(p.isAssigned());
}

test "parsing" {
    try std.testing.expectEqual(@as(?PersonId, @enumFromInt(7)), parsePersonId("7"));
    try std.testing.expectEqual(@as(?PersonId, null), parsePersonId("0"));
    try std.testing.expectEqual(@as(?PersonId, null), parsePersonId("seven"));
}

test "ids cost nothing" {
    try std.testing.expectEqual(@sizeOf(u32), @sizeOf(PersonId));
}
