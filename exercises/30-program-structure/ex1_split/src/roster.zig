//! A fixed-capacity roster indexed by PersonId.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");
const types = @import("domain/types.zig");
const Pilot = @import("domain/pilot.zig").Pilot;

pub const Roster = struct {
    slots: [16]Pilot = undefined,
    count: usize = 0,

    pub fn add(self: *Roster, p: Pilot) void {
        // TODO: implement this function.
        @panic("TODO");
    }

    pub fn get(self: *const Roster, id: types.PersonId) ?*const Pilot {
        // TODO: implement this function.
        @panic("TODO");
    }

    pub fn best(self: *const Roster) ?*const Pilot {
        // TODO: implement this function.
        @panic("TODO");
    }
};

test "roster" {
    var r = Roster{};
    try std.testing.expect(r.best() == null);
    r.add(Pilot.init("A", 4, 4));
    r.add(Pilot.init("B", 2, 2));
    try std.testing.expectEqualStrings("B", r.best().?.name);
    try std.testing.expect(r.get(@enumFromInt(5)) == null);
}
