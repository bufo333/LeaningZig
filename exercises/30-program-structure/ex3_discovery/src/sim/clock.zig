const std = @import("std");
pub const Clock = struct {
    day: u32 = 0,
    pub fn tick(self: *Clock) void {
        self.day += 1;
    }
    test "clock ticks" {
        var c = Clock{};
        c.tick();
        try std.testing.expectEqual(@as(u32, 1), c.day);
    }
};
test "clock starts at zero" {
    try std.testing.expectEqual(@as(u32, 0), (Clock{}).day);
}
