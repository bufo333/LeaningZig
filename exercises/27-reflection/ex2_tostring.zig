//! Chapter 27, exercise 2: a generic toString.
//! Run with:  zig test ex2_tostring.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

/// Write a readable form of `value` into `w`, choosing the format by type.
/// Structs print as {field=value, ...}, enums as their tag name, optionals
/// as "null" or the payload, []const u8 as quoted text.
pub fn toString(w: *std.Io.Writer, value: anytype) std.Io.Writer.Error!void {
    // TODO: implement this function.
    @panic("TODO");
}

/// Convenience: render into a fixed buffer and return the written slice.
pub fn toBuf(buf: []u8, value: anytype) ![]u8 {
    var w = std.Io.Writer.fixed(buf);
    try toString(&w, value);
    return w.buffered();
}

const Role = enum { pilot, tech };
const Pilot = struct { name: []const u8, role: Role, gunnery: u8, callsign: ?[]const u8 };

test "scalars" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqualStrings("42", try toBuf(&buf, @as(u8, 42)));
    try std.testing.expectEqualStrings("true", try toBuf(&buf, true));
    try std.testing.expectEqualStrings("tech", try toBuf(&buf, Role.tech));
    try std.testing.expectEqualStrings("null", try toBuf(&buf, @as(?u8, null)));
    try std.testing.expectEqualStrings("7", try toBuf(&buf, @as(?u8, 7)));
    try std.testing.expectEqualStrings("\"hi\"", try toBuf(&buf, @as([]const u8, "hi")));
}

test "arrays and structs" {
    var buf: [128]u8 = undefined;
    try std.testing.expectEqualStrings("[1, 2, 3]", try toBuf(&buf, [_]u8{ 1, 2, 3 }));
    const p = Pilot{ .name = "Kell", .role = .pilot, .gunnery = 3, .callsign = null };
    try std.testing.expectEqualStrings(
        "{name=\"Kell\", role=pilot, gunnery=3, callsign=null}",
        try toBuf(&buf, p),
    );
    const q = Pilot{ .name = "Ana", .role = .tech, .gunnery = 5, .callsign = "Wrench" };
    try std.testing.expectEqualStrings(
        "{name=\"Ana\", role=tech, gunnery=5, callsign=\"Wrench\"}",
        try toBuf(&buf, q),
    );
}

test "nested struct" {
    var buf: [128]u8 = undefined;
    const Pos = struct { x: i32, y: i32 };
    const Unit = struct { id: u16, pos: Pos };
    try std.testing.expectEqualStrings(
        "{id=9, pos={x=-1, y=4}}",
        try toBuf(&buf, Unit{ .id = 9, .pos = .{ .x = -1, .y = 4 } }),
    );
}
