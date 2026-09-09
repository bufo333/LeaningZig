//! Chapter 24, exercise 5: a fixed binary record with explicit byte order.
//! Run with:  zig test ex5_record.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// Wire format, 8 bytes, big-endian: id u32, armor u16, flags u8, pad u8 (zero).
const Record = struct { id: u32, armor: u16, flags: u8 };
const size = 8;

fn encode(r: Record, out: *[size]u8) void {
    _ = r;
    _ = out;
    // TODO
}

fn decode(in: *const [size]u8) !Record {
    _ = in;
    // TODO
}

test "known bytes" {
    var buf: [size]u8 = undefined;
    encode(.{ .id = 258, .armor = 0x0102, .flags = 0xAB }, &buf);
    try std.testing.expectEqualSlices(u8, &.{ 0, 0, 1, 2, 1, 2, 0xAB, 0 }, &buf);
}

test "round trip" {
    var buf: [size]u8 = undefined;
    const r: Record = .{ .id = 0xDEADBEEF, .armor = 65535, .flags = 7 };
    encode(r, &buf);
    try std.testing.expectEqual(r, try decode(&buf));
}

test "bad padding" {
    var buf: [size]u8 = .{ 0, 0, 0, 1, 0, 0, 0, 9 };
    try std.testing.expectError(error.BadPadding, decode(&buf));
    buf[7] = 0;
    try std.testing.expectEqual(@as(u32, 1), (try decode(&buf)).id);
}
