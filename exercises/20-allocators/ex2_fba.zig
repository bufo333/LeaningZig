//! Chapter 20, exercise 2: a fixed buffer runs out.
//! Run with:  zig test ex2_fba.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

/// Format `n` into memory taken from `a`. Caller frees.
fn label(a: std.mem.Allocator, n: u32) ![]u8 {
    return std.fmt.allocPrint(a, "unit-{d}", .{n});
}

/// How many labels fit in a buffer of `size` bytes before OutOfMemory?
fn countUntilFull(comptime size: usize) usize {
    // TODO: implement
    @panic("TODO");
}

test "labels come out of the buffer" {
    var buffer: [32]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const a = fba.allocator();
    const l = try label(a, 7);
    try std.testing.expectEqualStrings("unit-7", l);
    try std.testing.expect(fba.end_index >= 6);
}

test "a full buffer fails cleanly with OutOfMemory" {
    var buffer: [16]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const a = fba.allocator();
    _ = try label(a, 1);
    _ = try label(a, 2);
    try std.testing.expectError(error.OutOfMemory, label(a, 3));
}

test "bigger buffer, more labels" {
    try std.testing.expect(countUntilFull(64) < countUntilFull(256));
    try std.testing.expectEqual(@as(usize, 0), countUntilFull(4));
}
