//! Chapter 29, exercise 3: a lance roster as a bit set.
//! Run with:  zig test ex3_bitset.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const max_units = 64;
pub const Roster = std.bit_set.IntegerBitSet(max_units);

/// Units that are in `available` but not in `deployed`.
pub fn idle(available: Roster, deployed: Roster) Roster {
    // TODO: implement this function.
    @panic("TODO");
}

/// The lowest-numbered idle unit, if any.
pub fn firstIdle(available: Roster, deployed: Roster) ?usize {
    // TODO: implement this function.
    @panic("TODO");
}

/// Pack the roster into a u64 for a save file, and back.
pub fn toBits(r: Roster) u64 {
    // TODO: implement this function.
    @panic("TODO");
}
pub fn fromBits(bits: u64) Roster {
    // TODO: implement this function.
    @panic("TODO");
}

test "idle units" {
    var avail = Roster.initEmpty();
    avail.setRangeValue(.{ .start = 0, .end = 8 }, true);
    var dep = Roster.initEmpty();
    dep.set(1);
    dep.set(2);
    dep.set(5);
    const free = idle(avail, dep);
    try std.testing.expectEqual(@as(usize, 5), free.count());
    try std.testing.expect(free.isSet(0) and !free.isSet(1) and free.isSet(7));
    try std.testing.expectEqual(@as(?usize, 0), firstIdle(avail, dep));
    dep.set(0);
    try std.testing.expectEqual(@as(?usize, 3), firstIdle(avail, dep));
}

test "nobody idle" {
    const avail = Roster.initFull();
    const dep = Roster.initFull();
    try std.testing.expectEqual(@as(?usize, null), firstIdle(avail, dep));
}

test "round trip through u64" {
    var r = Roster.initEmpty();
    r.set(0);
    r.set(63);
    const bits = toBits(r);
    try std.testing.expectEqual(@as(u64, 1) | (@as(u64, 1) << 63), bits);
    try std.testing.expect(fromBits(bits).eql(r));
}
