//! Chapter 27, exercise 3: a generic deep equality.
//! Run with:  zig test ex3_equal.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

/// Deep structural equality. Slices compare by content, not by address.
pub fn eql(a: anytype, b: @TypeOf(a)) bool {
    // TODO: implement this function.
    @panic("TODO");
}

const Pilot = struct { name: []const u8, gunnery: u8, callsign: ?[]const u8 };
const Event = union(enum) { none, wound: u8, promoted: []const u8 };

test "scalars and optionals" {
    try std.testing.expect(eql(@as(u8, 3), 3));
    try std.testing.expect(!eql(@as(u8, 3), 4));
    try std.testing.expect(eql(@as(?u8, null), null));
    try std.testing.expect(!eql(@as(?u8, 1), null));
}

test "slices compare by content" {
    const a: []const u8 = "Kell";
    var storage = [_]u8{ 'K', 'e', 'l', 'l' };
    const b: []const u8 = storage[0..];
    try std.testing.expect(a.ptr != b.ptr);
    try std.testing.expect(eql(a, b));
    try std.testing.expect(!eql(a, @as([]const u8, "Kel")));
}

test "structs with slices and optionals" {
    const p = Pilot{ .name = "Kell", .gunnery = 3, .callsign = "Ace" };
    var q = Pilot{ .name = "Kell", .gunnery = 3, .callsign = "Ace" };
    try std.testing.expect(eql(p, q));
    q.callsign = null;
    try std.testing.expect(!eql(p, q));
    q.callsign = "Ace";
    q.gunnery = 4;
    try std.testing.expect(!eql(p, q));
}

test "tagged unions" {
    try std.testing.expect(eql(Event{ .wound = 2 }, Event{ .wound = 2 }));
    try std.testing.expect(!eql(Event{ .wound = 2 }, Event{ .wound = 3 }));
    try std.testing.expect(!eql(Event{ .wound = 2 }, Event.none));
    try std.testing.expect(eql(Event{ .promoted = "Sgt" }, Event{ .promoted = "Sgt" }));
}

test "arrays of structs" {
    const a = [_]Pilot{ .{ .name = "A", .gunnery = 1, .callsign = null } };
    const b = [_]Pilot{ .{ .name = "A", .gunnery = 1, .callsign = null } };
    try std.testing.expect(eql(a, b));
}
