//! A pilot record and the skill formula.
const std = @import("std");

pub const Pilot = struct {
    name: []const u8,
    gunnery: u8,
    piloting: u8,

    pub fn init(name: []const u8, gunnery: u8, piloting: u8) Pilot {
        return .{ .name = name, .gunnery = gunnery, .piloting = piloting };
    }

    /// Lower gunnery and piloting are better in BattleTech, so skill is
    /// the distance from the worst possible (8 + 8).
    pub fn skill(self: Pilot) u8 {
        return 16 - self.gunnery - self.piloting;
    }
};

test "skill" {
    try std.testing.expectEqual(@as(u8, 9), Pilot.init("x", 3, 4).skill());
}
