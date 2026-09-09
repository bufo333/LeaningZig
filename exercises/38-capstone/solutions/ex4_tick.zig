//! Chapter 38, stage 4: the daily tick and payday.
//! Run with:  zig test ex4_tick.zig
//! Goal: add Date and Clock, an `advance_days` command, and `advanceDay`,
//! which runs payroll on the first of every month.

const std = @import("std");

/// All money is integer C-bills. No floats in the ledger, ever.
pub const CBills = i64;

/// Basis points: 10_000 bp is x1.0.
pub const Bp = i64;

pub fn applyBp(amount: CBills, bp: Bp) CBills {
    return @divTrunc(amount * bp, 10_000);
}

pub const PersonId = enum(u32) { none = 0, _ };

pub const Role = enum {
    mekwarrior,
    tech,
    medic,
    admin,

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
    morale: i8 = 0,

    pub fn monthlySalary(self: Person) CBills {
        const bp: Bp = 10_000 + @as(Bp, self.morale) * 200;
        return applyBp(self.role.baseSalary(), bp);
    }
};

pub const Category = enum { payroll, severance, contract, event };

pub const Transaction = struct {
    day: u32,
    amount: CBills, // income +, expense -
    category: Category,
    note: []const u8 = "",
};

pub const Ledger = struct {
    transactions: std.ArrayList(Transaction) = .empty,

    pub fn post(self: *Ledger, alloc: std.mem.Allocator, txn: Transaction) !void {
        try self.transactions.append(alloc, txn);
    }

    /// Sum of every transaction: what the ledger says we have gained or lost.
    pub fn balance(self: Ledger) CBills {
        var total: CBills = 0;
        for (self.transactions.items) |t| total += t.amount;
        return total;
    }

    pub fn sumCategory(self: Ledger, cat: Category) CBills {
        var total: CBills = 0;
        for (self.transactions.items) |t| if (t.category == cat) {
            total += t.amount;
        };
        return total;
    }
};

/// Proleptic Gregorian date, as the game uses in 3025.
pub const Date = struct {
    year: u16,
    month: u8,
    day: u8,

    pub const campaign_start: Date = .{ .year = 3025, .month = 1, .day = 1 };

    pub fn isLeapYear(year: u16) bool {
        return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0;
    }

    pub fn daysInMonth(year: u16, month: u8) u8 {
        return switch (month) {
            1, 3, 5, 7, 8, 10, 12 => 31,
            4, 6, 9, 11 => 30,
            2 => if (isLeapYear(year)) @as(u8, 29) else 28,
            else => unreachable,
        };
    }

    pub fn next(self: Date) Date {
        var d = self;
        d.day += 1;
        if (d.day > daysInMonth(d.year, d.month)) {
            d.day = 1;
            d.month += 1;
            if (d.month > 12) {
                d.month = 1;
                d.year += 1;
            }
        }
        return d;
    }

    pub fn isPayday(self: Date) bool {
        return self.day == 1;
    }
};

pub const Clock = struct {
    date: Date = Date.campaign_start,
    day_index: u32 = 0,

    pub fn advance(self: *Clock) void {
        self.date = self.date.next();
        self.day_index += 1;
    }
};

pub const Error = error{ UnknownPerson, EmptyName, OutOfMemory };

pub const Company = struct {
    arena: std.heap.ArenaAllocator,
    people: std.ArrayList(Person) = .empty,
    next_id: u32 = 1,
    funds: CBills,
    starting_funds: CBills,
    ledger: Ledger = .{},
    clock: Clock = .{},

    pub const Options = struct {
        funds: CBills = 50_000,
    };

    pub fn init(gpa: std.mem.Allocator, opts: Options) Company {
        return .{
            .arena = std.heap.ArenaAllocator.init(gpa),
            .funds = opts.funds,
            .starting_funds = opts.funds,
        };
    }

    pub fn deinit(self: *Company) void {
        self.arena.deinit();
    }

    /// Every allocation the company makes comes from here and dies in deinit.
    pub fn allocator(self: *Company) std.mem.Allocator {
        return self.arena.allocator();
    }

    pub fn find(self: *Company, id: PersonId) ?*Person {
        for (self.people.items) |*p| if (p.id == id) return p;
        return null;
    }

    fn today(self: *Company) u32 {
        return self.clock.day_index;
    }

    pub fn hire(self: *Company, name: []const u8, role: Role) Error!PersonId {
        if (name.len == 0) return error.EmptyName;
        const id: PersonId = @enumFromInt(self.next_id);
        self.next_id += 1;
        const owned = try self.allocator().dupe(u8, name);
        try self.people.append(self.allocator(), .{
            .id = id,
            .name = owned,
            .role = role,
            .hired_day = self.today(),
        });
        return id;
    }

    pub fn fire(self: *Company, id: PersonId) Error!void {
        for (self.people.items, 0..) |p, i| {
            if (p.id == id) {
                try self.postTransaction(.{
                    .day = self.today(),
                    .amount = -p.monthlySalary(),
                    .category = .severance,
                    .note = p.name,
                });
                _ = self.people.orderedRemove(i);
                return;
            }
        }
        return error.UnknownPerson;
    }

    /// The only way money moves: a ledger entry and the balance, in lockstep.
    pub fn postTransaction(self: *Company, txn: Transaction) Error!void {
        try self.ledger.post(self.allocator(), txn);
        self.funds += txn.amount;
    }

    pub fn monthlyPayroll(self: *Company) CBills {
        var total: CBills = 0;
        for (self.people.items) |p| total += p.monthlySalary();
        return total;
    }

    pub fn runPayroll(self: *Company) Error!void {
        const payroll = self.monthlyPayroll();
        if (payroll == 0) return;
        try self.postTransaction(.{
            .day = self.today(),
            .amount = -payroll,
            .category = .payroll,
            .note = "monthly payroll",
        });
    }
};

pub const Command = union(enum) {
    hire: struct { name: []const u8, role: Role },
    fire: PersonId,
    advance_days: u32,
};

pub const Result = union(enum) {
    hired: PersonId,
    fired,
    advanced: u32,
};

pub fn execute(co: *Company, cmd: Command) Error!Result {
    switch (cmd) {
        .hire => |h| return .{ .hired = try co.hire(h.name, h.role) },
        .fire => |id| {
            try co.fire(id);
            return .fired;
        },
        .advance_days => |n| {
            for (0..n) |_| try advanceDay(co);
            return .{ .advanced = n };
        },
    }
}

/// One campaign day, in a fixed order of phases.
pub fn advanceDay(co: *Company) Error!void {
    co.clock.advance();
    if (co.clock.date.isPayday()) try co.runPayroll();
}

test "31 days from January 1st crosses exactly one payday" {
    var co = Company.init(std.testing.allocator, .{ .funds = 10_000 });
    defer co.deinit();
    _ = try execute(&co, .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } });
    const r = try execute(&co, .{ .advance_days = 31 });
    try std.testing.expectEqual(@as(u32, 31), r.advanced);
    try std.testing.expectEqual(Date{ .year = 3025, .month = 2, .day = 1 }, co.clock.date);
    try std.testing.expectEqual(@as(CBills, 8_500), co.funds);
    try std.testing.expectEqual(@as(u32, 31), co.ledger.transactions.items[0].day);
}

test "a year has twelve paydays" {
    var co = Company.init(std.testing.allocator, .{ .funds = 100_000 });
    defer co.deinit();
    _ = try execute(&co, .{ .hire = .{ .name = "Clay", .role = .tech } });
    _ = try execute(&co, .{ .advance_days = 365 });
    try std.testing.expectEqual(Date{ .year = 3026, .month = 1, .day = 1 }, co.clock.date);
    try std.testing.expectEqual(@as(usize, 12), co.ledger.transactions.items.len);
    try std.testing.expectEqual(@as(CBills, 100_000 - 12 * 800), co.funds);
}

test "hired_day records the clock" {
    var co = Company.init(std.testing.allocator, .{});
    defer co.deinit();
    _ = try execute(&co, .{ .advance_days = 10 });
    const r = try execute(&co, .{ .hire = .{ .name = "Lori", .role = .mekwarrior } });
    try std.testing.expectEqual(@as(u32, 10), co.find(r.hired).?.hired_day);
}
