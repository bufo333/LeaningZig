//! Chapter 35, exercise 4: @cImport and wrapping a C return code.
//! Run with:  zig run -lc ex4_cimport.zig
//! Goal: import <stdlib.h> and <errno.h> with @cImport, wrap strtol in a
//! Zig function that returns an error instead of a sentinel, and print:
//!   "42" -> 42
//!   "  -7" -> -7
//!   "12abc" -> error.TrailingGarbage
//!   "abc" -> error.NotANumber

const std = @import("std");
const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("errno.h");
});

const ParseError = error{ NotANumber, TrailingGarbage };

/// strtol reports failure by returning 0 and leaving `end` at the start,
/// or by stopping early. Turn both into Zig errors.
fn parseLong(text: [*:0]const u8) ParseError!c_long {
    var end: [*c]u8 = undefined;
    const v = c.strtol(text, &end, 10);
    if (end == @as([*c]u8, @constCast(text))) return error.NotANumber;
    if (end[0] != 0) return error.TrailingGarbage;
    return v;
}

pub fn main() void {
    const inputs = [_][*:0]const u8{ "42", "  -7", "12abc", "abc" };
    for (inputs) |s| {
        if (parseLong(s)) |v| {
            std.debug.print("\"{s}\" -> {d}\n", .{ s, v });
        } else |e| {
            std.debug.print("\"{s}\" -> {s}\n", .{ s, @errorName(e) });
        }
    }
}
