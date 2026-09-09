//! Chapter 27, exercise 5: enum tables from reflection.
//! Run with:  zig test ex5_enumtable.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Parse a tag name into an enum value, using only @typeInfo (no std.meta).
pub fn parseEnum(comptime E: type, text: []const u8) ?E {
    inline for (@typeInfo(E).@"enum".fields) |f| {
        if (std.mem.eql(u8, f.name, text)) return @enumFromInt(f.value);
    }
    return null;
}

/// All tag names of E, as a comptime array of strings, in declaration order.
pub fn names(comptime E: type) [@typeInfo(E).@"enum".fields.len][]const u8 {
    const fields = @typeInfo(E).@"enum".fields;
    var out: [fields.len][]const u8 = undefined;
    inline for (fields, 0..) |f, i| out[i] = f.name;
    return out;
}

/// A fixed array with one slot per enum tag, indexed by @intFromEnum.
pub fn Counter(comptime E: type) type {
    return struct {
        counts: [@typeInfo(E).@"enum".fields.len]u32 = @splat(0),
        const Self = @This();
        pub fn bump(self: *Self, e: E) void {
            self.counts[@intFromEnum(e)] += 1;
        }
        pub fn get(self: Self, e: E) u32 {
            return self.counts[@intFromEnum(e)];
        }
    };
}

const Role = enum { pilot, tech, medic, admin };

test "parseEnum" {
    try std.testing.expectEqual(@as(?Role, .medic), parseEnum(Role, "medic"));
    try std.testing.expectEqual(@as(?Role, null), parseEnum(Role, "cook"));
}

test "names" {
    const n = names(Role);
    try std.testing.expectEqual(@as(usize, 4), n.len);
    try std.testing.expectEqualStrings("pilot", n[0]);
    try std.testing.expectEqualStrings("admin", n[3]);
}

test "Counter" {
    var c = Counter(Role){};
    c.bump(.tech);
    c.bump(.tech);
    c.bump(.admin);
    try std.testing.expectEqual(@as(u32, 2), c.get(.tech));
    try std.testing.expectEqual(@as(u32, 0), c.get(.pilot));
    try std.testing.expectEqual(@as(usize, 4), c.counts.len);
}
