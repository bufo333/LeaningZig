//! Chapter 37, exercise 2: rename to the conventions.
//! Run with:  zig test ex2_naming.zig
//! Goal: the starter uses C-style and Java-style names. Rename every
//! identifier to Zig convention (TitleCase types, camelCase functions,
//! snake_case values) and add a doc comment to each public declaration.
//! The tests only check behaviour, so the compiler is your reviewer.

const std = @import("std");

/// Money in C-bills. Integer, always.
pub const CBills = i64;

/// A person's job in the company.
pub const Role = enum {
    mekwarrior,
    tech,

    /// Monthly pay before any modifiers.
    pub fn baseSalary(self: Role) CBills {
        return switch (self) {
            .mekwarrior => 1_500,
            .tech => 800,
        };
    }
};

/// One hired person.
pub const Person = struct {
    name: []const u8,
    role: Role,
    hired_day: u32,

    /// True once the person has served at least `min_days`.
    pub fn isVeteran(self: Person, today: u32, min_days: u32) bool {
        return today >= self.hired_day and today - self.hired_day >= min_days;
    }
};

/// Total monthly payroll for a roster.
pub fn monthlyPayroll(people: []const Person) CBills {
    var total: CBills = 0;
    for (people) |p| total += p.role.baseSalary();
    return total;
}

test "payroll adds the roster" {
    const roster = [_]Person{
        .{ .name = "Grayson", .role = .mekwarrior, .hired_day = 0 },
        .{ .name = "Clay", .role = .tech, .hired_day = 3 },
    };
    try std.testing.expectEqual(@as(CBills, 2_300), monthlyPayroll(&roster));
}

test "veteran after enough days" {
    const p: Person = .{ .name = "Lori", .role = .mekwarrior, .hired_day = 10 };
    try std.testing.expect(!p.isVeteran(40, 90));
    try std.testing.expect(p.isVeteran(100, 90));
}
