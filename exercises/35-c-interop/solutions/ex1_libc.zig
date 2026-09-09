//! Chapter 35, exercise 1: three libc functions by hand.
//! Run with:  zig run -lc ex1_libc.zig
//! Goal: declare strlen, getpid and toupper with `extern fn`, call them,
//! and print the results. Expected output (pid differs):
//!   strlen("Grayson Carlyle") = 15
//!   pid = 12345 (positive: true)
//!   toupper('m') = M

const std = @import("std");

extern fn strlen(s: [*:0]const u8) usize;
extern fn getpid() c_int;
extern fn toupper(ch: c_int) c_int;

pub fn main() void {
    const name: [*:0]const u8 = "Grayson Carlyle";
    std.debug.print("strlen(\"{s}\") = {d}\n", .{ name, strlen(name) });
    const pid = getpid();
    std.debug.print("pid = {d} (positive: {})\n", .{ pid, pid > 0 });
    const up: u8 = @intCast(toupper('m'));
    std.debug.print("toupper('m') = {c}\n", .{up});
}
