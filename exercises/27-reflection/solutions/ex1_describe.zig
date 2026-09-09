//! Chapter 27, exercise 1: describe a type.
//! Run with:  zig test ex1_describe.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Return a short human description of T, built only from @typeInfo.
pub fn describe(comptime T: type) []const u8 {
    return switch (@typeInfo(T)) {
        .int => |i| if (i.signedness == .signed) "signed int" else "unsigned int",
        .float => "float",
        .bool => "bool",
        .pointer => |p| if (p.size == .slice) "slice" else "pointer",
        .array => "array",
        .optional => "optional",
        .error_union => "error union",
        .@"struct" => "struct",
        .@"enum" => "enum",
        .@"union" => "union",
        .@"fn" => "function",
        else => "other",
    };
}

/// How many bits an int or float occupies. Compile error for anything else.
pub fn bitsOf(comptime T: type) u16 {
    return switch (@typeInfo(T)) {
        .int => |i| i.bits,
        .float => |f| f.bits,
        else => @compileError("bitsOf: not a number: " ++ @typeName(T)),
    };
}

/// True when T is an integer that can hold `n` without overflow.
pub fn fits(comptime T: type, n: comptime_int) bool {
    return n >= std.math.minInt(T) and n <= std.math.maxInt(T);
}

test "describe" {
    try std.testing.expectEqualStrings("unsigned int", describe(u8));
    try std.testing.expectEqualStrings("signed int", describe(i32));
    try std.testing.expectEqualStrings("float", describe(f16));
    try std.testing.expectEqualStrings("slice", describe([]const u8));
    try std.testing.expectEqualStrings("pointer", describe(*u8));
    try std.testing.expectEqualStrings("array", describe([3]u8));
    try std.testing.expectEqualStrings("optional", describe(?u8));
    try std.testing.expectEqualStrings("error union", describe(anyerror!void));
    try std.testing.expectEqualStrings("struct", describe(struct { a: u8 }));
    try std.testing.expectEqualStrings("enum", describe(enum { a, b }));
    try std.testing.expectEqualStrings("union", describe(union(enum) { a: u8 }));
    try std.testing.expectEqualStrings("function", describe(@TypeOf(describe)));
}

test "bitsOf" {
    try std.testing.expectEqual(@as(u16, 8), bitsOf(u8));
    try std.testing.expectEqual(@as(u16, 3), bitsOf(u3));
    try std.testing.expectEqual(@as(u16, 64), bitsOf(f64));
}

test "fits" {
    try std.testing.expect(fits(u8, 255));
    try std.testing.expect(!fits(u8, 256));
    try std.testing.expect(fits(i8, -128));
    try std.testing.expect(!fits(i8, 128));
}
