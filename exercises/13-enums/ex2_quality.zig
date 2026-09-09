//! Chapter 13, exercise 2: explicit tag types and conversions.
//! Run with:  zig test ex2_quality.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

/// Unit quality grades, worst to best. The integer is the index into tables.
const Quality = enum(u8) {
    f = 0,
    d = 1,
    c = 2,
    b = 3,
    a = 4,

    /// One grade better, capped at a. Hint: @intFromEnum, then @enumFromInt.
    pub fn improve(self: Quality) Quality {
        _ = self;
        // TODO
    }

    /// One grade worse, capped at f.
    pub fn degrade(self: Quality) Quality {
        _ = self;
        // TODO
    }

    /// Parse a single letter, either case. Anything else is null.
    pub fn parse(c: u8) ?Quality {
        _ = c;
        // TODO
    }

    /// Upper-case letter for display. Hint: @tagName(self)[0].
    pub fn letter(self: Quality) u8 {
        _ = self;
        // TODO
    }
};

test "size and values" {
    try std.testing.expectEqual(@as(usize, 1), @sizeOf(Quality));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(Quality.b));
}

test "improve and degrade clamp" {
    try std.testing.expectEqual(Quality.d, Quality.f.improve());
    try std.testing.expectEqual(Quality.a, Quality.a.improve());
    try std.testing.expectEqual(Quality.f, Quality.f.degrade());
    try std.testing.expectEqual(Quality.c, Quality.b.degrade());
}

test "parse and letter" {
    try std.testing.expectEqual(@as(?Quality, .b), Quality.parse('b'));
    try std.testing.expectEqual(@as(?Quality, .b), Quality.parse('B'));
    try std.testing.expectEqual(@as(?Quality, null), Quality.parse('x'));
    try std.testing.expectEqual(@as(u8, 'A'), Quality.a.letter());
}

test "histogram indexed by the tag" {
    var counts = [_]u32{0} ** 5;
    for ([_]Quality{ .a, .c, .a, .f }) |q| counts[@intFromEnum(q)] += 1;
    try std.testing.expectEqual([5]u32{ 1, 0, 1, 0, 2 }, counts);
}
