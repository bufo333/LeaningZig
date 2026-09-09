//! Chapter 37, exercise 2: rename to the conventions.
//! Run with:  zig test ex2_naming.zig
//! Goal: the starter uses C-style and Java-style names. Rename every
//! identifier to Zig convention (TitleCase types, camelCase functions,
//! snake_case values) and add a doc comment to each public declaration.
//! The tests only check behaviour, so the compiler is your reviewer.
//! STARTER: compiles and passes, but every name breaks convention. Rename.

const std = @import("std");

pub const c_bills_t = i64;

pub const ROLE = enum {
    Mekwarrior,
    Tech,

    pub fn GetBaseSalary(self: ROLE) c_bills_t {
        return switch (self) {
            .Mekwarrior => 1_500,
            .Tech => 800,
        };
    }
};

pub const PERSON = struct {
    Name: []const u8,
    Role: ROLE,
    HiredDay: u32,

    pub fn is_veteran(self: PERSON, Today: u32, MinDays: u32) bool {
        return Today >= self.HiredDay and Today - self.HiredDay >= MinDays;
    }
};

pub fn MonthlyPayroll(People: []const PERSON) c_bills_t {
    var Total: c_bills_t = 0;
    for (People) |p| Total += p.Role.GetBaseSalary();
    return Total;
}

test "payroll adds the roster" {
    const roster = [_]PERSON{
        .{ .Name = "Grayson", .Role = .Mekwarrior, .HiredDay = 0 },
        .{ .Name = "Clay", .Role = .Tech, .HiredDay = 3 },
    };
    try std.testing.expectEqual(@as(c_bills_t, 2_300), MonthlyPayroll(&roster));
}

test "veteran after enough days" {
    const p: PERSON = .{ .Name = "Lori", .Role = .Mekwarrior, .HiredDay = 10 };
    try std.testing.expect(!p.is_veteran(40, 90));
    try std.testing.expect(p.is_veteran(100, 90));
}
