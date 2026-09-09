//! Chapter 07, exercise 4: early returns instead of nested ifs.
//! Run with:  zig test ex4_early_return.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

/// Contract pay after adjustments, in C-bills:
///   - a base of 1000 per ton of the force
///   - zero if tonnage is zero (nothing to hire)
///   - doubled when the contract is a raid
///   - then a 10 percent bonus if reputation is 8 or more
/// Write it with early returns and no else branches.
fn contractPay(tonnage: u32, is_raid: bool, reputation: u8) u32 {
    if (tonnage == 0) return 0;
    var pay: u32 = tonnage * 1000;
    if (is_raid) pay *= 2;
    if (reputation < 8) return pay;
    return pay + pay / 10;
}

/// Describe a pilot's condition from wounds and fatigue:
/// "dead" when wounds >= 6, "hospitalised" when wounds >= 3,
/// "exhausted" when fatigue >= 80, otherwise "fit".
fn condition(wounds: u8, fatigue: u8) []const u8 {
    if (wounds >= 6) return "dead";
    if (wounds >= 3) return "hospitalised";
    if (fatigue >= 80) return "exhausted";
    return "fit";
}

test "contractPay" {
    try std.testing.expectEqual(@as(u32, 0), contractPay(0, true, 10));
    try std.testing.expectEqual(@as(u32, 100_000), contractPay(100, false, 5));
    try std.testing.expectEqual(@as(u32, 200_000), contractPay(100, true, 5));
    try std.testing.expectEqual(@as(u32, 220_000), contractPay(100, true, 8));
}

test "condition" {
    try std.testing.expectEqualStrings("dead", condition(6, 0));
    try std.testing.expectEqualStrings("hospitalised", condition(3, 100));
    try std.testing.expectEqualStrings("exhausted", condition(2, 80));
    try std.testing.expectEqualStrings("fit", condition(2, 79));
}
