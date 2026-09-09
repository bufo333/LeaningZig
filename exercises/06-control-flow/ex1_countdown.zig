//! Chapter 06, exercise 1: while, for and if together.
//! Run with:  zig run ex1_countdown.zig
//! Expected output (on stderr):
//!   T-5 T-4 T-3 T-2 T-1 launch
//!   1 2 fizz 4 buzz fizz 7 8 fizz buzz 11 fizz 13 14 fizzbuzz
//! Line 1: a while loop with a continue expression counting 5 down to 1.
//! Line 2: a for loop over 1..16 printing fizz/buzz/fizzbuzz/the number,
//! separated by single spaces, with a newline after the last one.
const std = @import("std");

pub fn main() void {
    // TODO: countdown line
    // TODO: fizzbuzz line
    std.debug.print("TODO\n", .{});
}
