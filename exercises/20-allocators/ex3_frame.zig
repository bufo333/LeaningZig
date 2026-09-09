//! Chapter 20, exercise 3: one arena per frame, reset between frames.
//! Run with:  zig test ex3_frame.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

/// One frame's worth of work: a few formatted rows, never freed one by one.
fn drawFrame(a: std.mem.Allocator, frame_no: u32) !usize {
    var bytes: usize = 0;
    var i: u32 = 0;
    while (i < 20) : (i += 1) {
        const row = try std.fmt.allocPrint(a, "frame {d} row {d}", .{ frame_no, i });
        bytes += row.len;
    }
    return bytes;
}

/// Run `frames` frames through one arena, resetting it between frames
/// so that its capacity stops growing after the first frame.
/// Returns the arena's capacity after the last frame.
fn runFrames(gpa: std.mem.Allocator, frames: u32) !usize {
    // TODO: implement
    @panic("TODO");
}

test "capacity does not grow with the number of frames" {
    const one = try runFrames(std.testing.allocator, 1);
    const many = try runFrames(std.testing.allocator, 200);
    try std.testing.expect(one > 0);
    try std.testing.expectEqual(one, many);
}
