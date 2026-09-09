//! Chapter 28, exercise 1: a typed design catalogue from a .zon file.
//! Run with:  zig build test   (inside exercises/28-zon/ex1_designs/)
//! Goal: fill in `Design`, import the catalogue, and make every test pass.
const std = @import("std");

pub const Rarity = enum { common, uncommon, rare };

pub const Design = struct {
    key: []const u8,
    name: []const u8,
    tonnage: u32,
    rarity: Rarity,
    walk_mp: u8 = 4,
    jump_mp: u8 = 0,

    pub fn weightClass(self: Design) []const u8 {
        if (self.tonnage <= 35) return "light";
        if (self.tonnage <= 55) return "medium";
        if (self.tonnage <= 75) return "heavy";
        return "assault";
    }
};

pub const catalog: []const Design = @import("designs.zon");

pub fn find(key: []const u8) ?Design {
    for (catalog) |d| if (std.mem.eql(u8, d.key, key)) return d;
    return null;
}

pub fn countByRarity(r: Rarity) usize {
    var n: usize = 0;
    for (catalog) |d| if (d.rarity == r) {
        n += 1;
    };
    return n;
}

test "catalogue has four designs" {
    try std.testing.expectEqual(@as(usize, 4), catalog.len);
}

test "defaults fill in unspecified fields" {
    const whm = find("WHM-6R").?;
    try std.testing.expectEqual(@as(u8, 4), whm.walk_mp);
    try std.testing.expectEqual(@as(u8, 0), whm.jump_mp);
    try std.testing.expectEqual(@as(u8, 8), find("LCT-1V").?.walk_mp);
}

test "find and weight classes" {
    try std.testing.expectEqualStrings("assault", find("AS7-D").?.weightClass());
    try std.testing.expectEqualStrings("medium", find("SHD-2H").?.weightClass());
    try std.testing.expect(find("nope") == null);
}

test "rarity counts" {
    try std.testing.expectEqual(@as(usize, 2), countByRarity(.common));
    try std.testing.expectEqual(@as(usize, 1), countByRarity(.rare));
}

test "every key is unique and every tonnage is a multiple of 5" {
    for (catalog, 0..) |a, i| {
        try std.testing.expect(a.tonnage % 5 == 0);
        for (catalog[i + 1 ..]) |b| try std.testing.expect(!std.mem.eql(u8, a.key, b.key));
    }
}
