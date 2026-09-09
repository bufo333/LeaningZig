//! Chapter 38, stage 1: the vocabulary of Small Ledger.
//! Run with:  zig test ex1_types.zig
//! Goal: define CBills, applyBp, PersonId, Role with baseSalary, and
//! Person with monthlySalary, so the tests pass.
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

// TODO: define CBills, Bp, applyBp, PersonId, Role (with baseSalary) and
// Person (with monthlySalary). See chapter 38.2.

test "basis points stay in integers" {
    try std.testing.expectEqual(@as(CBills, 1_500), applyBp(1_500, 10_000));
    try std.testing.expectEqual(@as(CBills, 1_650), applyBp(1_500, 11_000));
    try std.testing.expectEqual(@as(CBills, 900), applyBp(1_500, 6_000));
}

test "typed ids are distinct values" {
    const a: PersonId = @enumFromInt(1);
    const b: PersonId = @enumFromInt(2);
    try std.testing.expect(a != b);
    try std.testing.expect(a != .none);
    try std.testing.expectEqual(@as(u32, 2), @intFromEnum(b));
}

test "salary follows role and morale" {
    var p: Person = .{ .id = @enumFromInt(1), .name = "Grayson", .role = .mekwarrior, .hired_day = 0 };
    try std.testing.expectEqual(@as(CBills, 1_500), p.monthlySalary());
    p.morale = 5;
    try std.testing.expectEqual(@as(CBills, 1_650), p.monthlySalary());
    p.morale = -10;
    try std.testing.expectEqual(@as(CBills, 1_200), p.monthlySalary());
}
