//! Chapter 38, stage 2: a Company and its commands.
//! Run with:  zig test ex2_company.zig
//! Goal: add a Company that owns its people through an arena, and a
//! tagged-union Command with an `execute` function that returns errors.
//! STARTER: this file does not compile until you fill in the TODOs.

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

// TODO (stage 2): add `pub const Error`, `pub const Company` (arena, people,
// next_id, day, funds; init/deinit/allocator/find/hire/fire), `Command`,
// `Result` and `execute`. See chapter 38.3.

test "hire gives increasing ids and copies the name" {
    var co = Company.init(std.testing.allocator, .{});
    defer co.deinit();
    var name_buf = [_]u8{ 'C', 'l', 'a', 'y' };
    const a = try execute(&co, .{ .hire = .{ .name = &name_buf, .role = .tech } });
    name_buf[0] = 'X'; // the company must not be looking at our buffer
    const b = try execute(&co, .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } });
    try std.testing.expectEqual(@as(u32, 1), @intFromEnum(a.hired));
    try std.testing.expectEqual(@as(u32, 2), @intFromEnum(b.hired));
    try std.testing.expectEqualStrings("Clay", co.find(a.hired).?.name);
}

test "fire removes and refuses unknown ids" {
    var co = Company.init(std.testing.allocator, .{});
    defer co.deinit();
    const r = try execute(&co, .{ .hire = .{ .name = "Lori", .role = .mekwarrior } });
    try std.testing.expectEqual(@as(usize, 1), co.people.items.len);
    _ = try execute(&co, .{ .fire = r.hired });
    try std.testing.expectEqual(@as(usize, 0), co.people.items.len);
    try std.testing.expectError(error.UnknownPerson, execute(&co, .{ .fire = r.hired }));
    try std.testing.expectError(error.EmptyName, execute(&co, .{ .hire = .{ .name = "", .role = .medic } }));
}
