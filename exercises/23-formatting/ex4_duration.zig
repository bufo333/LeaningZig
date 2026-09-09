//! Chapter 23, exercise 4: a custom format method.
//! Run with:  zig test ex4_duration.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODOs.
const std = @import("std");

const Duration = struct {
    seconds: u64,

    /// "2d 3h 4m 5s", omitting any leading zero units; "0s" for zero.
    pub fn format(self: Duration, w: *std.Io.Writer) std.Io.Writer.Error!void {
        _ = self;
        _ = w;
        // TODO
    }
};

fn render(buf: []u8, d: Duration) ![]u8 {
    return std.fmt.bufPrint(buf, "{f}", .{d});
}

test "format" {
    var buf: [32]u8 = undefined;
    try std.testing.expectEqualStrings("0s", try render(&buf, .{ .seconds = 0 }));
    try std.testing.expectEqualStrings("45s", try render(&buf, .{ .seconds = 45 }));
    try std.testing.expectEqualStrings("2m 5s", try render(&buf, .{ .seconds = 125 }));
    try std.testing.expectEqualStrings("1h 0m 0s", try render(&buf, .{ .seconds = 3600 }));
    try std.testing.expectEqualStrings("2d 3h 4m 5s", try render(&buf, .{ .seconds = 2 * 86400 + 3 * 3600 + 4 * 60 + 5 }));
}

test "works with allocPrint too" {
    const s = try std.fmt.allocPrint(std.testing.allocator, "eta {f}", .{Duration{ .seconds = 90 }});
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings("eta 1m 30s", s);
}
