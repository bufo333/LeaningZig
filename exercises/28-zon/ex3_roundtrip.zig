//! Chapter 28, exercise 3: serialize a value to ZON and read it back.
//! Run with:  zig test ex3_roundtrip.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const Pilot = struct { name: []const u8, gunnery: u8, piloting: u8 };
pub const Roster = struct { day: u32, funds: i64, pilots: []const Pilot };

/// Render `value` as ZON text into `buf`; return the written slice.
/// `pretty` chooses multi-line Zig style; false gives one compact line.
pub fn toZon(buf: []u8, value: anytype, pretty: bool) ![]u8 {
    // TODO: implement this function.
    @panic("TODO");
}

/// Parse ZON text back into a Roster, allocating from `arena`.
/// The text must be sentinel-terminated: copy it with allocator.dupeZ first.
pub fn fromZon(arena: std.mem.Allocator, text: []const u8) !Roster {
    // TODO: implement this function.
    @panic("TODO");
}

test "round trip" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const pilots = [_]Pilot{
        .{ .name = "Kell", .gunnery = 3, .piloting = 4 },
        .{ .name = "Ana", .gunnery = 5, .piloting = 5 },
    };
    const before = Roster{ .day = 12, .funds = -3_500, .pilots = &pilots };
    var buf: [1024]u8 = undefined;
    const text = try toZon(&buf, before, true);
    try std.testing.expect(std.mem.indexOf(u8, text, ".name = \"Kell\"") != null);
    const after = try fromZon(arena.allocator(), text);
    try std.testing.expectEqual(before.day, after.day);
    try std.testing.expectEqual(before.funds, after.funds);
    try std.testing.expectEqual(@as(usize, 2), after.pilots.len);
    try std.testing.expectEqualStrings("Ana", after.pilots[1].name);
    try std.testing.expectEqual(@as(u8, 5), after.pilots[1].gunnery);
}

test "pretty and compact forms" {
    var buf: [256]u8 = undefined;
    const p = Pilot{ .name = "X", .gunnery = 1, .piloting = 2 };
    try std.testing.expectEqualStrings(
        ".{\n    .name = \"X\",\n    .gunnery = 1,\n    .piloting = 2,\n}",
        try toZon(&buf, p, true),
    );
    try std.testing.expectEqualStrings(".{.name=\"X\",.gunnery=1,.piloting=2}", try toZon(&buf, p, false));
}
