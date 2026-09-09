//! Chapter 23, exercise 2: parse "q,r" hex coordinates.
//! Run with:  zig test ex2_coords.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Hex = struct { q: i16, r: i16 };
const ParseError = error{ MissingComma, BadNumber };

/// "3,-2" -> Hex{ .q = 3, .r = -2 }. Spaces around the numbers are allowed.
fn parseHex(text: []const u8) ParseError!Hex {
    _ = text;
    // TODO
}

test "good input" {
    try std.testing.expectEqual(Hex{ .q = 3, .r = -2 }, try parseHex("3,-2"));
    try std.testing.expectEqual(Hex{ .q = 0, .r = 7 }, try parseHex(" 0 , 7 "));
}

test "bad input" {
    try std.testing.expectError(error.MissingComma, parseHex("3 -2"));
    try std.testing.expectError(error.BadNumber, parseHex("3,x"));
    try std.testing.expectError(error.BadNumber, parseHex(",2"));
    try std.testing.expectError(error.BadNumber, parseHex("40000,0")); // overflow of i16
}
