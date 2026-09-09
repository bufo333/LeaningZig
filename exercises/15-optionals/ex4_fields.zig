//! Chapter 15, exercise 4: optional fields and optional pointers.
//! Run with:  zig test ex4_fields.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

const Person = struct {
    name: []const u8,
    born_day: ?i32 = null,
    leave_until_day: ?u32 = null,

    /// Available unless on leave that has not yet ended.
    fn isAvailable(self: Person, day: u32) bool {
        // TODO: implement
        @panic("TODO");
    }
};

/// Pointer to the person with the smallest known birthday, or null if
/// nobody has a birthday on record.
fn oldest(people: []const Person) ?*const Person {
    // TODO: implement
    @panic("TODO");
}

/// Pointer to the first available person, or null.
fn firstAvailable(people: []const Person, day: u32) ?*const Person {
    // TODO: implement
    @panic("TODO");
}

const crew = [_]Person{
    .{ .name = "Ada", .born_day = 200, .leave_until_day = 40 },
    .{ .name = "Bo" },
    .{ .name = "Cy", .born_day = 120 },
};

test "isAvailable" {
    try std.testing.expect(!crew[0].isAvailable(30));
    try std.testing.expect(crew[0].isAvailable(41));
    try std.testing.expect(crew[1].isAvailable(0));
}

test "oldest skips unknown birthdays" {
    const o = oldest(&crew) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("Cy", o.name);
    const nobody = [_]Person{ .{ .name = "X" }, .{ .name = "Y" } };
    try std.testing.expect(oldest(&nobody) == null);
}

test "firstAvailable" {
    try std.testing.expectEqualStrings("Bo", firstAvailable(&crew, 10).?.name);
    try std.testing.expectEqualStrings("Ada", firstAvailable(&crew, 50).?.name);
    const all_away = [_]Person{.{ .name = "Z", .leave_until_day = 99 }};
    try std.testing.expect(firstAvailable(&all_away, 10) == null);
}
