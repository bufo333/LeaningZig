//! Chapter 30, exercise 2: use a file-as-struct.
//! Run with:  zig build test   (inside ex2_counter/)
const std = @import("std");
const Ledger = @import("Ledger.zig");

test "use the ledger" {
    const gpa = std.testing.allocator;
    var l = Ledger.init(1000);
    defer l.deinit(gpa);
    try l.apply(gpa, -250);
    try l.apply(gpa, 75);
    l.nextDay();
    try std.testing.expectEqual(@as(i64, 825), l.funds);
    try std.testing.expectEqual(@as(u32, 2), l.day);
    try std.testing.expectEqual(@as(usize, 2), l.log.items.len);
}

test {
    _ = Ledger;
}
