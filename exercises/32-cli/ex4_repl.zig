//! Chapter 32, exercise 4: a calculator REPL.
//! Run with:  zig run ex4_repl.zig
//! Then type lines such as  2 + 3  or  10 * 4 , and  quit  to leave.
//! Expected output for  printf '2 + 3\n10 / 4\n7 % 0\nquit\n' | zig run ex4_repl.zig
//!   > 5
//!   > 2
//!   > error: DivisionByZero
//!   > bye
//! Prompt goes to stdout and is flushed before each read. EOF ends the loop
//! exactly like "quit".
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

const Error = error{ BadSyntax, BadNumber, DivisionByZero, UnknownOperator };

fn eval(line: []const u8) Error!i64 {
    // TODO: implement this function.
    @panic("TODO");
}

pub fn main(init: std.process.Init) !void {
    // TODO: implement this function.
    @panic("TODO");
}

test "eval" {
    try std.testing.expectEqual(@as(i64, 5), try eval("2 + 3"));
    try std.testing.expectEqual(@as(i64, -8), try eval("2 * -4"));
    try std.testing.expectError(error.DivisionByZero, eval("1 / 0"));
    try std.testing.expectError(error.BadSyntax, eval("1 +"));
    try std.testing.expectError(error.UnknownOperator, eval("1 ^ 2"));
}
