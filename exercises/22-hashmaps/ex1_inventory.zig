//! Chapter 22, exercise 1: a parts inventory keyed by part number.
//! Run with:  zig test ex1_inventory.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Inventory = struct {
    parts: std.AutoHashMapUnmanaged(u32, u32) = .empty,

    fn deinit(self: *Inventory, gpa: std.mem.Allocator) void {
        self.parts.deinit(gpa);
    }

    /// Add `n` of part `id` (creating the entry if needed).
    fn stock(self: *Inventory, gpa: std.mem.Allocator, id: u32, n: u32) !void {
        _ = self;
        _ = gpa;
        _ = id;
        _ = n;
        // TODO
    }

    /// Take `n` of part `id`. Returns false (and changes nothing) if there are not enough.
    /// When the count hits zero the entry is removed.
    fn take(self: *Inventory, id: u32, n: u32) bool {
        _ = self;
        _ = id;
        _ = n;
        // TODO
    }

    fn onHand(self: Inventory, id: u32) u32 {
        _ = self;
        _ = id;
        // TODO
    }
};

test "stock and take" {
    const a = std.testing.allocator;
    var inv: Inventory = .{};
    defer inv.deinit(a);
    try inv.stock(a, 100, 3);
    try inv.stock(a, 100, 2);
    try inv.stock(a, 200, 1);
    try std.testing.expectEqual(@as(u32, 5), inv.onHand(100));
    try std.testing.expect(inv.take(100, 4));
    try std.testing.expect(!inv.take(100, 4));
    try std.testing.expectEqual(@as(u32, 1), inv.onHand(100));
    try std.testing.expectEqual(@as(u32, 0), inv.onHand(999));
}

test "taking the last one removes the key" {
    const a = std.testing.allocator;
    var inv: Inventory = .{};
    defer inv.deinit(a);
    try inv.stock(a, 7, 1);
    try std.testing.expect(inv.take(7, 1));
    try std.testing.expect(!inv.parts.contains(7));
    try std.testing.expectEqual(@as(u32, 0), inv.parts.count());
}
