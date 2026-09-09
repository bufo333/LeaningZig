//! Chapter 32, exercise 5: exit codes that scripts can trust.
//! Run with:  zig run ex5_exitcodes.zig -- 12 30
//! Expected output (stdout): "42" and exit status 0. With no arguments: "0".
//! Rules: --help          -> usage on stderr, status 0;
//!        any other --flag -> usage on stderr, status 64 (EX_USAGE);
//!        a non-number     -> message on stderr, status 65 (EX_DATAERR);
//!        the word "abort" anywhere -> std.process.exit(70) immediately.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub fn main(init: std.process.Init) u8 {
    // TODO: implement this function.
    @panic("TODO");
}
