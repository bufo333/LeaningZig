//! Chapter 24, exercise 4: EnumArray and a bit set.
//! Run with:  zig test ex4_payroll.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Role = enum { pilot, tech, medic, admin };
const Person = struct { role: Role, salary: u32, day_off: u3 }; // day 0..6

/// Total salary per role.
fn payroll(people: []const Person) std.enums.EnumArray(Role, u64) {
    var totals = std.enums.EnumArray(Role, u64).initFill(0);
    for (people) |p| totals.getPtr(p.role).* += p.salary;
    return totals;
}

/// Which days of the week (0..6) is at least one person off?
fn daysOff(people: []const Person) std.bit_set.IntegerBitSet(7) {
    var days = std.bit_set.IntegerBitSet(7).initEmpty();
    for (people) |p| days.set(p.day_off);
    return days;
}

/// First day nobody is off, or null if every day has someone away.
fn firstFullStrengthDay(people: []const Person) ?u3 {
    const off = daysOff(people);
    var all = std.bit_set.IntegerBitSet(7).initFull();
    all.setIntersection(off.complement());
    const first = all.findFirstSet() orelse return null;
    return @intCast(first);
}

const crew = [_]Person{
    .{ .role = .pilot, .salary = 1500, .day_off = 0 },
    .{ .role = .pilot, .salary = 1200, .day_off = 1 },
    .{ .role = .tech, .salary = 900, .day_off = 1 },
    .{ .role = .medic, .salary = 1100, .day_off = 5 },
};

test "payroll" {
    const t = payroll(&crew);
    try std.testing.expectEqual(@as(u64, 2700), t.get(.pilot));
    try std.testing.expectEqual(@as(u64, 900), t.get(.tech));
    try std.testing.expectEqual(@as(u64, 0), t.get(.admin));
}

test "days" {
    const off = daysOff(&crew);
    try std.testing.expectEqual(@as(usize, 3), off.count());
    try std.testing.expect(off.isSet(5));
    try std.testing.expect(!off.isSet(2));
    try std.testing.expectEqual(@as(?u3, 2), firstFullStrengthDay(&crew));
    const everyone = [_]Person{
        .{ .role = .tech, .salary = 1, .day_off = 0 }, .{ .role = .tech, .salary = 1, .day_off = 1 },
        .{ .role = .tech, .salary = 1, .day_off = 2 }, .{ .role = .tech, .salary = 1, .day_off = 3 },
        .{ .role = .tech, .salary = 1, .day_off = 4 }, .{ .role = .tech, .salary = 1, .day_off = 5 },
        .{ .role = .tech, .salary = 1, .day_off = 6 },
    };
    try std.testing.expectEqual(@as(?u3, null), firstFullStrengthDay(&everyone));
}
