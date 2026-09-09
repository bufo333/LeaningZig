//! Chapter 20, exercise 4: an allocator that counts.
//! Run with:  zig test ex4_counting.zig
//! Goal: make every test pass without changing the tests. Implement the
//! four vtable functions by forwarding to `child` and keeping the tallies.
const std = @import("std");

const Counting = struct {
    child: std.mem.Allocator,
    allocs: usize = 0,
    frees: usize = 0,
    bytes_requested: usize = 0,

    fn allocator(self: *Counting) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &vtable };
    }

    const vtable: std.mem.Allocator.VTable = .{
        .alloc = alloc,
        .resize = resize,
        .remap = remap,
        .free = free,
    };

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        const self: *Counting = @ptrCast(@alignCast(ctx));
        const p = self.child.rawAlloc(len, alignment, ret_addr);
        if (p != null) {
            self.allocs += 1;
            self.bytes_requested += len;
        }
        return p;
    }

    fn resize(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        const self: *Counting = @ptrCast(@alignCast(ctx));
        return self.child.rawResize(memory, alignment, new_len, ret_addr);
    }

    fn remap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *Counting = @ptrCast(@alignCast(ctx));
        return self.child.rawRemap(memory, alignment, new_len, ret_addr);
    }

    fn free(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        const self: *Counting = @ptrCast(@alignCast(ctx));
        self.frees += 1;
        self.child.rawFree(memory, alignment, ret_addr);
    }
};

test "counts allocs, frees and bytes" {
    var c = Counting{ .child = std.testing.allocator };
    const a = c.allocator();

    const x = try a.alloc(u8, 10);
    const y = try a.alloc(u32, 4);
    try std.testing.expectEqual(@as(usize, 2), c.allocs);
    try std.testing.expectEqual(@as(usize, 26), c.bytes_requested);
    a.free(x);
    a.free(y);
    try std.testing.expectEqual(@as(usize, 2), c.frees);
}

test "a list balances its allocations" {
    var c = Counting{ .child = std.testing.allocator };
    const a = c.allocator();
    {
        var list: std.ArrayList(u64) = .empty;
        defer list.deinit(a);
        var i: u64 = 0;
        while (i < 500) : (i += 1) try list.append(a, i);
    }
    try std.testing.expect(c.allocs > 0);
    try std.testing.expectEqual(c.allocs, c.frees);
}
