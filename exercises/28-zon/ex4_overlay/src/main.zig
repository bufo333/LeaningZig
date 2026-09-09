//! Chapter 28, exercise 4: a mod overlay with addAnonymousImport.
//! Run with:  zig build run   and   zig build run -Ddata=mods/hardcore
//!            zig build test  validates whichever table is bound.
const std = @import("std");

pub const Tuning = struct {
    person: struct { fatigue_tired: u8, exhausted_fatigue: u8, turnover_target: u8 },
    market: struct { fab_cost_bp: u32, fab_days: u32 },
};

pub const t: Tuning = @import("tuning_zon");

pub fn main() void {
    std.debug.print("tired {d} exhausted {d} turnover {d}\n", .{ t.person.fatigue_tired, t.person.exhausted_fatigue, t.person.turnover_target });
    std.debug.print("fab {d} bp, {d} days\n", .{ t.market.fab_cost_bp, t.market.fab_days });
}

test "tired comes before exhausted" {
    try std.testing.expect(t.person.fatigue_tired < t.person.exhausted_fatigue);
}

test "basis points are sane" {
    try std.testing.expect(t.market.fab_cost_bp <= 100_000);
}
