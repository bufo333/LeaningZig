//! Chapter 21, exercise 5: run-length encoding into a list of structs.
//! Run with:  zig test ex5_rle.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Run = struct { byte: u8, count: u32 };

fn encode(gpa: std.mem.Allocator, input: []const u8) ![]Run {
    var runs: std.ArrayList(Run) = .empty;
    errdefer runs.deinit(gpa);
    for (input) |c| {
        if (runs.items.len > 0 and runs.items[runs.items.len - 1].byte == c) {
            runs.items[runs.items.len - 1].count += 1;
        } else {
            try runs.append(gpa, .{ .byte = c, .count = 1 });
        }
    }
    return runs.toOwnedSlice(gpa);
}

fn decode(gpa: std.mem.Allocator, runs: []const Run) ![]u8 {
    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(gpa);
    for (runs) |r| try out.appendNTimes(gpa, r.byte, r.count);
    return out.toOwnedSlice(gpa);
}

test "encode" {
    const runs = try encode(std.testing.allocator, "aaabccdddd");
    defer std.testing.allocator.free(runs);
    try std.testing.expectEqual(@as(usize, 4), runs.len);
    try std.testing.expectEqual(Run{ .byte = 'a', .count = 3 }, runs[0]);
    try std.testing.expectEqual(Run{ .byte = 'd', .count = 4 }, runs[3]);
}

test "round trip" {
    const text = "mmmmeeeeccchhh warrior";
    const runs = try encode(std.testing.allocator, text);
    defer std.testing.allocator.free(runs);
    const back = try decode(std.testing.allocator, runs);
    defer std.testing.allocator.free(back);
    try std.testing.expectEqualStrings(text, back);
}

test "empty" {
    const runs = try encode(std.testing.allocator, "");
    defer std.testing.allocator.free(runs);
    try std.testing.expectEqual(@as(usize, 0), runs.len);
}
