//! Chapter 24, exercise 3: sort by several keys, then binary search.
//! Run with:  zig test ex3_sort_search.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Unit = struct { name: []const u8, tons: u32, bv: u32 };

/// Heaviest first; equal tonnage sorts by name A to Z.
fn byWeightThenName(_: void, a: Unit, b: Unit) bool {
    if (a.tons != b.tons) return a.tons > b.tons;
    return std.mem.lessThan(u8, a.name, b.name);
}

/// Sort by name only (for searching).
fn byName(_: void, a: Unit, b: Unit) bool {
    return std.mem.lessThan(u8, a.name, b.name);
}

fn cmpName(key: []const u8, item: Unit) std.math.Order {
    return std.mem.order(u8, key, item.name);
}

/// Index of the unit called `name` in a name-sorted slice, or null.
fn findByName(units: []const Unit, name: []const u8) ?usize {
    return std.sort.binarySearch(Unit, units, name, cmpName);
}

fn fixture() [5]Unit {
    return .{
        .{ .name = "Marauder", .tons = 75, .bv = 1363 },
        .{ .name = "Atlas", .tons = 100, .bv = 1897 },
        .{ .name = "Locust", .tons = 20, .bv = 432 },
        .{ .name = "Warhammer", .tons = 70, .bv = 1363 },
        .{ .name = "Archer", .tons = 70, .bv = 1300 },
    };
}

test "weight then name" {
    var units = fixture();
    std.mem.sort(Unit, &units, {}, byWeightThenName);
    try std.testing.expectEqualStrings("Atlas", units[0].name);
    try std.testing.expectEqualStrings("Marauder", units[1].name);
    try std.testing.expectEqualStrings("Archer", units[2].name); // 70 tons, A before W
    try std.testing.expectEqualStrings("Warhammer", units[3].name);
    try std.testing.expectEqualStrings("Locust", units[4].name);
}

test "binary search by name" {
    var units = fixture();
    std.mem.sort(Unit, &units, {}, byName);
    try std.testing.expect(std.sort.isSorted(Unit, &units, {}, byName));
    try std.testing.expectEqual(@as(?usize, 0), findByName(&units, "Archer"));
    try std.testing.expectEqual(@as(?usize, 4), findByName(&units, "Warhammer"));
    try std.testing.expectEqual(@as(?usize, null), findByName(&units, "Rifleman"));
}
