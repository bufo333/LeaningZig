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
const std = @import("std");

const Error = error{ BadSyntax, BadNumber, DivisionByZero, UnknownOperator };

fn eval(line: []const u8) Error!i64 {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    const a_text = it.next() orelse return error.BadSyntax;
    const op = it.next() orelse return error.BadSyntax;
    const b_text = it.next() orelse return error.BadSyntax;
    if (it.next() != null) return error.BadSyntax;
    const a = std.fmt.parseInt(i64, a_text, 10) catch return error.BadNumber;
    const b = std.fmt.parseInt(i64, b_text, 10) catch return error.BadNumber;
    if (op.len != 1) return error.UnknownOperator;
    return switch (op[0]) {
        '+' => a + b,
        '-' => a - b,
        '*' => a * b,
        '/' => if (b == 0) error.DivisionByZero else @divTrunc(a, b),
        '%' => if (b == 0) error.DivisionByZero else @rem(a, b),
        else => error.UnknownOperator,
    };
}

pub fn main(init: std.process.Init) !void {
    var rbuf: [1024]u8 = undefined;
    var stdin = std.Io.File.stdin().reader(init.io, &rbuf);
    const in = &stdin.interface;
    var wbuf: [1024]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &wbuf);
    const out = &stdout.interface;

    while (true) {
        try out.writeAll("> ");
        try out.flush();
        const raw = try in.takeDelimiter('\n') orelse break;
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;
        if (std.mem.eql(u8, line, "quit")) break;
        if (eval(line)) |v| {
            try out.print("{d}\n", .{v});
        } else |err| {
            try out.print("error: {s}\n", .{@errorName(err)});
        }
    }
    try out.writeAll("bye\n");
    try out.flush();
}

test "eval" {
    try std.testing.expectEqual(@as(i64, 5), try eval("2 + 3"));
    try std.testing.expectEqual(@as(i64, -8), try eval("2 * -4"));
    try std.testing.expectError(error.DivisionByZero, eval("1 / 0"));
    try std.testing.expectError(error.BadSyntax, eval("1 +"));
    try std.testing.expectError(error.UnknownOperator, eval("1 ^ 2"));
}
