//! Chapter 34, exercise 3: a seeded shuffle.
//! Run with:  zig test ex3_shuffle.zig
//! Goal: implement `shuffledCopy` so the tests pass. A shuffle must keep
//! every element exactly once, and the same seed must give the same order.

const std = @import("std");

const names = [_][]const u8{ "Grayson", "Lori", "Clay", "Delmar", "Ricol", "Yorinaga" };

/// Return a shuffled copy of `names`, driven by `seed`.
pub fn shuffledCopy(seed: u64) [names.len][]const u8 {
    var copy = names;
    var prng = std.Random.DefaultPrng.init(seed);
    prng.random().shuffle([]const u8, &copy);
    return copy;
}

fn contains(haystack: []const []const u8, needle: []const u8) bool {
    for (haystack) |h| if (std.mem.eql(u8, h, needle)) return true;
    return false;
}

test "every name survives the shuffle" {
    const s = shuffledCopy(1);
    for (names) |n| try std.testing.expect(contains(&s, n));
    try std.testing.expectEqual(names.len, s.len);
}

test "same seed gives same order" {
    const a = shuffledCopy(2024);
    const b = shuffledCopy(2024);
    for (a, b) |x, y| try std.testing.expectEqualStrings(x, y);
}

test "different seeds usually differ" {
    const a = shuffledCopy(1);
    const b = shuffledCopy(2);
    var same = true;
    for (a, b) |x, y| if (!std.mem.eql(u8, x, y)) {
        same = false;
    };
    try std.testing.expect(!same);
}
