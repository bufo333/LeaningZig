//! Chapter 05, exercise 4: a formatted float report.
//! Run with:  zig run ex4_report.zig
//! Expected output (on stderr):
//!   Locust        20 t   1512000 C-bills   75600.00 per ton
//!   Shadow Hawk   55 t   4701000 C-bills   85472.73 per ton
//!   Atlas        100 t   9626000 C-bills   96260.00 per ton
//!   average price per ton: 85777.58
//! Columns: name 12 wide left; tons 3 wide right; price 9 wide right;
//! per-ton 10 wide right with 2 decimals. One space between columns.
const std = @import("std");

/// Price divided by tonnage, as a float.
fn perTon(price: u32, tons: u32) f64 {
    _ = price;
    _ = tons;
    return 0; // TODO
}

pub fn main() void {
    const names = [_][]const u8{ "Locust", "Shadow Hawk", "Atlas" };
    const tons = [_]u32{ 20, 55, 100 };
    const prices = [_]u32{ 1_512_000, 4_701_000, 9_626_000 };
    var total: f64 = 0.0;
    for (names, tons, prices) |name, t, price| {
        const ratio = perTon(price, t);
        total += ratio;
        // TODO: print one row with the widths described in the header.
        _ = name;
    }
    // TODO: print the average line (total / 3.0).
    total += 0.0;
}
