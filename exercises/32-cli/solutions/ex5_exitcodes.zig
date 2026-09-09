//! Chapter 32, exercise 5: exit codes that scripts can trust.
//! Run with:  zig run ex5_exitcodes.zig -- 12 30
//! Expected output (stdout): "42" and exit status 0. With no arguments: "0".
//! Rules: --help          -> usage on stderr, status 0;
//!        any other --flag -> usage on stderr, status 64 (EX_USAGE);
//!        a non-number     -> message on stderr, status 65 (EX_DATAERR);
//!        the word "abort" anywhere -> std.process.exit(70) immediately.
const std = @import("std");

pub fn main(init: std.process.Init) u8 {
    var obuf: [128]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &obuf);
    const out = &stdout.interface;

    var it = std.process.Args.Iterator.init(init.minimal.args);
    _ = it.next();
    var sum: i64 = 0;
    while (it.next()) |arg| {
        if (std.mem.eql(u8, arg, "--help")) {
            std.debug.print("usage: exitcodes [--help] N [N...]\n", .{});
            return 0;
        }
        if (std.mem.startsWith(u8, arg, "--")) {
            std.debug.print("unknown flag {s}\nusage: exitcodes [--help] N [N...]\n", .{arg});
            return 64;
        }
        if (std.mem.eql(u8, arg, "abort")) {
            std.debug.print("aborting on request\n", .{});
            std.process.exit(70);
        }
        const n = std.fmt.parseInt(i64, arg, 10) catch {
            std.debug.print("not a number: {s}\n", .{arg});
            return 65;
        };
        sum += n;
    }
    out.print("{d}\n", .{sum}) catch return 74;
    out.flush() catch return 74;
    return 0;
}
