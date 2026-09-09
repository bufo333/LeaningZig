//! Chapter 18, exercise 2: mutate a struct through a pointer.
//! Run with:  zig test ex2_mutate.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Pilot = struct {
    name: []const u8,
    gunnery: u8,
    piloting: u8,
    missions: u32 = 0,
};

/// One mission survived: missions + 1; every 3rd mission improves
/// gunnery by one (lower is better, minimum 0).
fn survive(p: *Pilot) void {
    p.missions += 1;
    if (p.missions % 3 == 0 and p.gunnery > 0) p.gunnery -= 1;
}

/// Sum of both skills. Takes a pointer to const: it only reads.
fn rating(p: *const Pilot) u8 {
    return p.gunnery + p.piloting;
}

/// Apply `survive` to every pilot in the slice, in place.
fn surviveAll(pilots: []Pilot) void {
    for (pilots) |*p| survive(p);
}

test "survive mutates the caller's pilot" {
    var ada = Pilot{ .name = "Ada", .gunnery = 4, .piloting = 5 };
    survive(&ada);
    survive(&ada);
    try std.testing.expectEqual(@as(u32, 2), ada.missions);
    try std.testing.expectEqual(@as(u8, 4), ada.gunnery);
    survive(&ada);
    try std.testing.expectEqual(@as(u8, 3), ada.gunnery);
    try std.testing.expectEqual(@as(u8, 8), rating(&ada));
}

test "surviveAll" {
    var lance = [_]Pilot{
        .{ .name = "A", .gunnery = 4, .piloting = 5, .missions = 2 },
        .{ .name = "B", .gunnery = 0, .piloting = 5, .missions = 2 },
    };
    surviveAll(&lance);
    try std.testing.expectEqual(@as(u8, 3), lance[0].gunnery);
    try std.testing.expectEqual(@as(u8, 0), lance[1].gunnery);
    try std.testing.expectEqual(@as(u32, 3), lance[1].missions);
}
