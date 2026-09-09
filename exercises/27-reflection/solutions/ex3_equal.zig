//! Chapter 27, exercise 3: a generic deep equality.
//! Run with:  zig test ex3_equal.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Deep structural equality. Slices compare by content, not by address.
pub fn eql(a: anytype, b: @TypeOf(a)) bool {
    const T = @TypeOf(a);
    switch (@typeInfo(T)) {
        .void => return true,
        .int, .comptime_int, .float, .comptime_float, .bool, .@"enum" => return a == b,
        .optional => {
            if (a == null and b == null) return true;
            if (a == null or b == null) return false;
            return eql(a.?, b.?);
        },
        .array => {
            for (a, b) |x, y| if (!eql(x, y)) return false;
            return true;
        },
        .pointer => |p| switch (p.size) {
            .one => return eql(a.*, b.*),
            .slice => {
                if (a.len != b.len) return false;
                for (a, b) |x, y| if (!eql(x, y)) return false;
                return true;
            },
            else => @compileError("eql: unsupported pointer " ++ @typeName(T)),
        },
        .@"struct" => |info| {
            inline for (info.fields) |f| {
                if (!eql(@field(a, f.name), @field(b, f.name))) return false;
            }
            return true;
        },
        .@"union" => |info| {
            if (info.tag_type == null) @compileError("eql: untagged union " ++ @typeName(T));
            const Tag = info.tag_type.?;
            const ta: Tag = a;
            const tb: Tag = b;
            if (ta != tb) return false;
            inline for (info.fields) |f| {
                if (ta == @field(Tag, f.name)) {
                    return eql(@field(a, f.name), @field(b, f.name));
                }
            }
            unreachable;
        },
        else => @compileError("eql: unsupported type " ++ @typeName(T)),
    }
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
