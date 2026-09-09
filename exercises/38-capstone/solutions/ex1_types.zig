//! Chapter 38, stage 1: the vocabulary of Small Ledger.
//! Run with:  zig test ex1_types.zig
//! Goal: define CBills, applyBp, PersonId, Role with baseSalary, and
//! Person with monthlySalary, so the tests pass.

const std = @import("std");

/// All money is integer C-bills. No floats in the ledger, ever.
pub const CBills = i64;

/// Basis points: 10_000 bp is x1.0. All multipliers go through this so
/// the arithmetic is integer and reproducible.
pub const Bp = i64;

pub fn applyBp(amount: CBills, bp: Bp) CBills {
    return @divTrunc(amount * bp, 10_000);
}

/// A typed ID: impossible to mix up with a plain integer or another ID.
pub const PersonId = enum(u32) { none = 0, _ };

pub const Role = enum {
    mekwarrior,
    tech,
    medic,
    admin,

    /// Monthly base pay.
    pub fn baseSalary(self: Role) CBills {
        return switch (self) {
            .mekwarrior => 1_500,
            .tech => 800,
            .medic => 400,
            .admin => 500,
        };
    }
};

pub const Person = struct {
    id: PersonId,
    name: []const u8,
    role: Role,
    hired_day: u32,
    /// -10 (mutinous) to +10 (devoted). Each point is 2 percent of pay.
    morale: i8 = 0,

    /// Base pay adjusted by morale: +2 percent per point.
    pub fn monthlySalary(self: Person) CBills {
        const bp: Bp = 10_000 + @as(Bp, self.morale) * 200;
        return applyBp(self.role.baseSalary(), bp);
    }
};

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
