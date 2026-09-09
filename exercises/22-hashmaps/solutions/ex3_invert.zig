//! Chapter 22, exercise 3: invert a map.
//! Run with:  zig test ex3_invert.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Callsigns = std.AutoArrayHashMapUnmanaged(u32, []const u8); // pilot id -> callsign
const ByCallsign = std.StringArrayHashMapUnmanaged(u32); // callsign -> pilot id

/// Build the reverse map. If two pilots share a callsign, return error.Duplicate.
/// The callsign strings are shared with the input map, not copied.
fn invert(gpa: std.mem.Allocator, in: Callsigns) !ByCallsign {
    var out: ByCallsign = .empty;
    errdefer out.deinit(gpa);
    var it = in.iterator();
    while (it.next()) |e| {
        const gop = try out.getOrPut(gpa, e.value_ptr.*);
        if (gop.found_existing) return error.Duplicate;
        gop.value_ptr.* = e.key_ptr.*;
    }
    return out;
}

test "invert" {
    const a = std.testing.allocator;
    var cs: Callsigns = .empty;
    defer cs.deinit(a);
    try cs.put(a, 1, "Widowmaker");
    try cs.put(a, 2, "Phantom");
    try cs.put(a, 3, "Grey");
    var by = try invert(a, cs);
    defer by.deinit(a);
    try std.testing.expectEqual(@as(?u32, 2), by.get("Phantom"));
    try std.testing.expectEqual(@as(?u32, null), by.get("Nobody"));
    try std.testing.expectEqual(@as(usize, 3), by.count());
    // ArrayHashMap keeps the order we inserted in.
    try std.testing.expectEqualStrings("Widowmaker", by.keys()[0]);
    try std.testing.expectEqualStrings("Grey", by.keys()[2]);
}

test "duplicate callsign is an error and leaks nothing" {
    const a = std.testing.allocator;
    var cs: Callsigns = .empty;
    defer cs.deinit(a);
    try cs.put(a, 1, "Ace");
    try cs.put(a, 2, "Ace");
    try std.testing.expectError(error.Duplicate, invert(a, cs));
}
