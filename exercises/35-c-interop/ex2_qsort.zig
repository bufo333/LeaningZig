//! Chapter 35, exercise 2: qsort with a Zig comparator.
//! Run with:  zig run -lc ex2_qsort.zig
//! Goal: sort an array of salaries with libc's qsort, using a comparator
//! written in Zig with callconv(.c). Expected output:
//!   before: { 1500, 400, 800, 640, 1500, 500 }
//!   after:  { 400, 500, 640, 800, 1500, 1500 }
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

// TODO: a function-pointer type for the comparator, and the qsort declaration.

// TODO: fn byValue(a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int

pub fn main() void {
    var salaries = [_]i64{ 1500, 400, 800, 640, 1500, 500 };
    std.debug.print("before: {any}\n", .{salaries});
    // TODO: call qsort
    std.debug.print("after:  {any}\n", .{salaries});
}
