//! Chapter 18, exercise 5: do not keep a pointer across a growth.
//! Run with:  zig test ex5_stale.zig
//! Goal: make every test pass without changing the tests. `recruit`
//! must never read through a pointer that may have gone stale.
const std = @import("std");

const Pilot = struct { name: []const u8, wingman: ?usize = null };

/// Add `name`, then pair the new pilot with the previous one as wingmen.
/// Returns the index of the new pilot. Hold INDICES, not pointers,
/// across the append: appending may move the whole buffer.
fn recruit(a: std.mem.Allocator, list: *std.ArrayList(Pilot), name: []const u8) !usize {
    const new_index = list.items.len;
    try list.append(a, .{ .name = name });
    if (new_index > 0) {
        const prev = new_index - 1;
        list.items[new_index].wingman = prev;
        list.items[prev].wingman = new_index;
    }
    return new_index;
}

test "pairing survives many reallocations" {
    const a = std.testing.allocator;
    var list: std.ArrayList(Pilot) = .empty;
    defer list.deinit(a);

    var i: usize = 0;
    while (i < 5000) : (i += 1) {
        const idx = try recruit(a, &list, "pilot");
        try std.testing.expectEqual(i, idx);
    }
    try std.testing.expectEqual(@as(?usize, 1), list.items[0].wingman);
    try std.testing.expectEqual(@as(?usize, 2), list.items[1].wingman);
    try std.testing.expectEqual(@as(?usize, 4999), list.items[4998].wingman);
    try std.testing.expectEqual(@as(?usize, 4998), list.items[4999].wingman);
}
