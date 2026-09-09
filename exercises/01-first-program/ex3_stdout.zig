//! Chapter 01, exercise 3: the same greeting, written to stdout.
//! Run with:  zig run ex3_stdout.zig
//! Expected output (on stdout, so `zig run ex3_stdout.zig 2>/dev/null` still shows it):
//!   Hello from stdout!
//!   The answer is 42.
//! This starter compiles but prints nothing. Find out why, then fix it.
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var buf: [1024]u8 = undefined;
    var w = std.Io.File.stdout().writer(init.io, &buf);
    const out = &w.interface;
    try out.print("Hello from stdout!\n", .{});
    // TODO: print "The answer is 42." using a {d} placeholder.
    // TODO: something is missing at the end of main. What is it?
}
