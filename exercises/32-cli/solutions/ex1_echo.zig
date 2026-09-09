//! Chapter 32, exercise 1: echo with options.
//! Run with:  zig run ex1_echo.zig -- -n hello world
//! Expected output (for the command above, on stdout):
//!   hello world
//! With no arguments it prints an empty line. `-n` suppresses the newline,
//! `-u` upper-cases every word.
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var buf: [1024]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &buf);
    const out = &stdout.interface;

    var newline = true;
    var upper = false;
    var first = true;
    var it = std.process.Args.Iterator.init(init.minimal.args);
    _ = it.next();
    while (it.next()) |arg| {
        if (std.mem.eql(u8, arg, "-n")) {
            newline = false;
            continue;
        }
        if (std.mem.eql(u8, arg, "-u")) {
            upper = true;
            continue;
        }
        if (!first) try out.writeByte(' ');
        first = false;
        if (upper) {
            for (arg) |c| try out.writeByte(std.ascii.toUpper(c));
        } else {
            try out.writeAll(arg);
        }
    }
    if (newline) try out.writeByte('\n');
    try out.flush();
}
