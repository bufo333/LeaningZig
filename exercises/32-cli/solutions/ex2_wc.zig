//! Chapter 32, exercise 2: a tiny `wc`.
//! Run with:  printf 'a b\nc\n' | zig run ex2_wc.zig
//! Expected output (for the command above):
//!   2 lines, 3 words, 6 bytes
//! Reads all of stdin line by line; prints one summary line to stdout.
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var rbuf: [4096]u8 = undefined;
    var stdin = std.Io.File.stdin().reader(init.io, &rbuf);
    const in = &stdin.interface;
    var wbuf: [256]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &wbuf);
    const out = &stdout.interface;

    var lines: u64 = 0;
    var words: u64 = 0;
    var bytes: u64 = 0;
    while (try in.takeDelimiter('\n')) |line| {
        lines += 1;
        bytes += line.len + 1;
        var it = std.mem.tokenizeAny(u8, line, " \t\r");
        while (it.next()) |_| words += 1;
    }
    try out.print("{d} lines, {d} words, {d} bytes\n", .{ lines, words, bytes });
    try out.flush();
}
