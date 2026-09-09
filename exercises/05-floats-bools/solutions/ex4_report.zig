//! Chapter 05, exercise 4: a formatted float report.
//! Run with:  zig run ex4_report.zig
//! Expected output (on stderr):
//!   Locust        20 t   1512000 C-bills   75600.00 per ton
//!   Shadow Hawk   55 t   4701000 C-bills   85472.73 per ton
//!   Atlas        100 t   9626000 C-bills   96260.00 per ton
//!   average price per ton: 85777.58
const std = @import("std");

fn perTon(price: u32, tons: u32) f64 {
    const p: f64 = @floatFromInt(price);
    const t: f64 = @floatFromInt(tons);
    return p / t;
}

pub fn main() void {
    const names = [_][]const u8{ "Locust", "Shadow Hawk", "Atlas" };
    const tons = [_]u32{ 20, 55, 100 };
    const prices = [_]u32{ 1_512_000, 4_701_000, 9_626_000 };
    var total: f64 = 0.0;
    for (names, tons, prices) |name, t, price| {
        const ratio = perTon(price, t);
        total += ratio;
        std.debug.print("{s:<12} {d:>3} t {d:>9} C-bills {d:>10.2} per ton\n", .{
            name, t, price, ratio,
        });
    }
    std.debug.print("average price per ton: {d:.2}\n", .{total / 3.0});
}
