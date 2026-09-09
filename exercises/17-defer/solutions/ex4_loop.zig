//! Chapter 17, exercise 4: defer inside a loop runs every iteration.
//! Run with:  zig test ex4_loop.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// A fake file handle that counts opens and closes on a shared tally.
const Tally = struct { opens: u32 = 0, closes: u32 = 0, max_open: u32 = 0, open_now: u32 = 0 };

fn open(t: *Tally) void {
    t.opens += 1;
    t.open_now += 1;
    if (t.open_now > t.max_open) t.max_open = t.open_now;
}
fn close(t: *Tally) void {
    t.closes += 1;
    t.open_now -= 1;
}

/// Process `n` files one after another. Each must be closed before the
/// next is opened, and every file must be closed even when `fail_at`
/// makes the function return early with an error.
fn processAll(t: *Tally, n: u32, fail_at: ?u32) !void {
    var i: u32 = 0;
    while (i < n) : (i += 1) {
        open(t);
        defer close(t);
        if (fail_at) |f| if (i == f) return error.Corrupt;
    }
}

test "every open is matched by a close, one at a time" {
    var t = Tally{};
    try processAll(&t, 5, null);
    try std.testing.expectEqual(@as(u32, 5), t.opens);
    try std.testing.expectEqual(@as(u32, 5), t.closes);
    try std.testing.expectEqual(@as(u32, 1), t.max_open);
}

test "an early error still closes the current file" {
    var t = Tally{};
    try std.testing.expectError(error.Corrupt, processAll(&t, 5, 2));
    try std.testing.expectEqual(@as(u32, 3), t.opens);
    try std.testing.expectEqual(@as(u32, 3), t.closes);
    try std.testing.expectEqual(@as(u32, 0), t.open_now);
}
