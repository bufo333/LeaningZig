//! Chapter 29, exercise 1: a status byte as a packed struct.
//! Run with:  zig test ex1_flags.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// One byte of pilot status, low bit first. Must fit exactly in a u8.
pub const Status = packed struct(u8) {
    active: bool = false,
    wounded: bool = false,
    veteran: bool = false,
    rank: u3 = 0, // 0..7
    morale: u2 = 1, // 0 = broken, 3 = fanatical

    pub fn toByte(self: Status) u8 {
        return @bitCast(self);
    }
    pub fn fromByte(b: u8) Status {
        return @bitCast(b);
    }
    /// How many of the three boolean flags are set.
    pub fn flagCount(self: Status) u4 {
        const low: u3 = @truncate(self.toByte());
        return @popCount(low);
    }
};

test "layout" {
    try std.testing.expectEqual(@as(usize, 1), @sizeOf(Status));
    try std.testing.expectEqual(@as(usize, 8), @bitSizeOf(Status));
    try std.testing.expectEqual(@as(usize, 3), @bitOffsetOf(Status, "rank"));
    try std.testing.expectEqual(@as(usize, 6), @bitOffsetOf(Status, "morale"));
}

test "to and from byte" {
    const s = Status{ .active = true, .veteran = true, .rank = 5, .morale = 3 };
    try std.testing.expectEqual(@as(u8, 0b11_101_101), s.toByte());
    const back = Status.fromByte(0b01_010_010);
    try std.testing.expect(!back.active and back.wounded and !back.veteran);
    try std.testing.expectEqual(@as(u3, 2), back.rank);
    try std.testing.expectEqual(@as(u2, 1), back.morale);
}

test "flag count" {
    try std.testing.expectEqual(@as(u4, 0), (Status{}).flagCount());
    try std.testing.expectEqual(@as(u4, 2), (Status{ .active = true, .wounded = true, .rank = 7 }).flagCount());
    try std.testing.expectEqual(@as(u4, 3), Status.fromByte(0xFF).flagCount());
}
