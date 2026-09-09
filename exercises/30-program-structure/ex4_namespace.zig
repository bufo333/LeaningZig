//! Chapter 30, exercise 4: namespaces inside one file.
//! Run with:  zig test ex4_namespace.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

/// A namespace: a struct with no fields, used only to group declarations.
pub const money = struct {
    pub const CBills = i64;
    pub fn fromCbills(n: i64) CBills {
        return n * 100;
    }
    fn hidden() void {}
};

pub const Stack = struct {
    items: [8]u32 = undefined,
    len: usize = 0,

    const Self = @This();

    pub fn push(self: *Self, v: u32) void {
        // TODO: implement this function.
        @panic("TODO");
    }
    pub fn pop(self: *Self) ?u32 {
        // TODO: implement this function.
        @panic("TODO");
    }
};

/// The file itself is a struct too. This returns it.
pub fn thisFile() type {
    // TODO: implement this function.
    @panic("TODO");
}

test "namespace has no size" {
    try std.testing.expectEqual(@as(usize, 0), @sizeOf(money));
    try std.testing.expectEqual(@as(money.CBills, 300), money.fromCbills(3));
}

test "Self works like the type name" {
    var s = Stack{};
    s.push(1);
    s.push(2);
    try std.testing.expectEqual(@as(?u32, 2), s.pop());
    try std.testing.expect(@TypeOf(s) == Stack);
}

test "visibility is per declaration" {
    try std.testing.expect(@hasDecl(money, "fromCbills"));
    try std.testing.expect(@hasDecl(money, "hidden"));
    try std.testing.expect(!@hasDecl(money, "nope"));
}

test "the file is a struct" {
    try std.testing.expect(@typeInfo(thisFile()) == .@"struct");
    try std.testing.expect(@hasDecl(thisFile(), "Stack"));
}
