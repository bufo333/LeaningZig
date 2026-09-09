//! Chapter 21, exercise 2: remove every matching element, two ways.
//! Run with:  zig test ex2_remove_all.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

/// Remove every element equal to `value`, keeping the order of the rest.
/// Returns how many were removed. Hint: orderedRemove, and think about `i`.
fn removeAllOrdered(list: *std.ArrayList(i32), value: i32) usize {
    _ = list;
    _ = value;
    // TODO
}

/// Same, but order does not matter, so use the cheaper swapRemove.
/// Hint: walk backwards.
fn removeAllFast(list: *std.ArrayList(i32), value: i32) usize {
    _ = list;
    _ = value;
    // TODO
}

test "ordered removal keeps order" {
    const a = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(a);
    try list.appendSlice(a, &.{ 7, 1, 7, 2, 7, 3, 7 });
    try std.testing.expectEqual(@as(usize, 4), removeAllOrdered(&list, 7));
    try std.testing.expectEqualSlices(i32, &.{ 1, 2, 3 }, list.items);
}

test "fast removal keeps the right elements" {
    const a = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(a);
    try list.appendSlice(a, &.{ 7, 1, 7, 2, 7, 3, 7 });
    try std.testing.expectEqual(@as(usize, 4), removeAllFast(&list, 7));
    std.mem.sort(i32, list.items, {}, std.sort.asc(i32));
    try std.testing.expectEqualSlices(i32, &.{ 1, 2, 3 }, list.items);
}

test "nothing to remove" {
    const a = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(a);
    try list.appendSlice(a, &.{ 1, 2 });
    try std.testing.expectEqual(@as(usize, 0), removeAllFast(&list, 9));
    try std.testing.expectEqual(@as(usize, 2), list.items.len);
}
