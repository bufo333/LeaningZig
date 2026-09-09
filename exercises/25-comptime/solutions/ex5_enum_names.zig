//! Chapter 25, exercise 5: tables derived from an enum at compile time.
//! Run with:  zig test ex5_enum_names.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// An array of every tag name of enum E, in declaration order.
fn names(comptime E: type) [@typeInfo(E).@"enum".fields.len][]const u8 {
    const fields = @typeInfo(E).@"enum".fields;
    var out: [fields.len][]const u8 = undefined;
    inline for (fields, 0..) |f, i| out[i] = f.name;
    return out;
}

/// Every value of E, in declaration order, matching names(E) index for index.
fn values(comptime E: type) [@typeInfo(E).@"enum".fields.len]E {
    const fields = @typeInfo(E).@"enum".fields;
    var out: [fields.len]E = undefined;
    inline for (fields, 0..) |f, i| out[i] = @enumFromInt(f.value);
    return out;
}

/// The length of the longest tag name, for sizing a column.
fn longestName(comptime E: type) usize {
    comptime var best: usize = 0;
    inline for (@typeInfo(E).@"enum".fields) |f| best = @max(best, f.name.len);
    return best;
}

/// Look a value up by name at runtime, using the compile-time table.
fn fromName(comptime E: type, text: []const u8) ?E {
    const table = comptime names(E);
    const vals = comptime values(E);
    for (table, vals) |n, v| {
        if (std.mem.eql(u8, n, text)) return v;
    }
    return null;
}

const Role = enum { pilot, tech, medic, quartermaster };
const Weather = enum(u8) { clear = 1, rain = 5, storm = 9 };

test "names" {
    const n = names(Role);
    try std.testing.expectEqual(@as(usize, 4), n.len);
    try std.testing.expectEqualStrings("pilot", n[0]);
    try std.testing.expectEqualStrings("quartermaster", n[3]);
}

test "longest" {
    const w = comptime longestName(Role);
    const col: [w]u8 = @splat(' ');
    try std.testing.expectEqual(@as(usize, 13), col.len);
    try std.testing.expectEqual(@as(usize, 5), comptime longestName(Weather));
}

test "fromName with explicit values" {
    try std.testing.expectEqual(@as(?Weather, .storm), fromName(Weather, "storm"));
    try std.testing.expectEqual(@as(?Weather, null), fromName(Weather, "snow"));
    try std.testing.expectEqual(@as(?Role, .medic), fromName(Role, "medic"));
}
