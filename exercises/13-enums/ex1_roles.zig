//! Chapter 13, exercise 1: an enum with methods.
//! Run with:  zig test ex1_roles.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO bodies.
const std = @import("std");

const Role = enum {
    mekwarrior,
    aero_pilot,
    tech,
    astech,
    doctor,
    medic,
    admin,

    /// mekwarrior, aero_pilot, doctor: 1500; tech: 800; astech, medic: 400; admin: 500.
    pub fn baseSalary(self: Role) i64 {
        _ = self;
        // TODO: an exhaustive switch, grouping cases with commas
    }

    /// Only mekwarrior and aero_pilot are combat roles.
    pub fn isCombat(self: Role) bool {
        _ = self;
        // TODO
    }

    /// astech -> tech, medic -> doctor, everyone else -> admin, admin -> null.
    pub fn supervisor(self: Role) ?Role {
        _ = self;
        // TODO
    }
};

test "salaries" {
    try std.testing.expectEqual(@as(i64, 1_500), Role.mekwarrior.baseSalary());
    try std.testing.expectEqual(@as(i64, 400), Role.medic.baseSalary());
    try std.testing.expectEqual(@as(i64, 500), Role.admin.baseSalary());
}

test "combat" {
    try std.testing.expect(Role.aero_pilot.isCombat());
    try std.testing.expect(!Role.tech.isCombat());
}

test "supervisor chain" {
    try std.testing.expectEqual(@as(?Role, .tech), Role.astech.supervisor());
    try std.testing.expectEqual(@as(?Role, .admin), Role.tech.supervisor());
    try std.testing.expectEqual(@as(?Role, null), Role.admin.supervisor());
}

test "payroll over every role" {
    var total: i64 = 0;
    for (std.enums.values(Role)) |r| total += r.baseSalary();
    try std.testing.expectEqual(@as(i64, 6_600), total);
}
