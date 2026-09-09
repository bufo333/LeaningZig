//! A fixed-capacity roster indexed by PersonId.
const std = @import("std");
const types = @import("domain/types.zig");
const Pilot = @import("domain/pilot.zig").Pilot;

pub const Roster = struct {
    slots: [16]Pilot = undefined,
    count: usize = 0,

    pub fn add(self: *Roster, p: Pilot) void {
        self.slots[self.count] = p;
        self.count += 1;
    }

    pub fn get(self: *const Roster, id: types.PersonId) ?*const Pilot {
        if (id.index() >= self.count) return null;
        return &self.slots[id.index()];
    }

    pub fn best(self: *const Roster) ?*const Pilot {
        if (self.count == 0) return null;
        var top: usize = 0;
        for (self.slots[0..self.count], 0..) |p, i| {
            if (p.skill() > self.slots[top].skill()) top = i;
        }
        return &self.slots[top];
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
