//! Chapter 38, stage 3: a ledger of transactions and payroll.
//! Run with:  zig test ex3_ledger.zig
//! Goal: add Transaction, Ledger, Company.postTransaction (the only way
//! money moves), monthlyPayroll and runPayroll; firing now posts severance.

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

pub const Error = error{ UnknownPerson, EmptyName, OutOfMemory };

pub const Company = struct {
    arena: std.heap.ArenaAllocator,
    people: std.ArrayList(Person) = .empty,
    next_id: u32 = 1,
    day: u32 = 0,
    funds: CBills,
    starting_funds: CBills,
    ledger: Ledger = .{},

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
        return self.day;
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
};

pub const Result = union(enum) {
    hired: PersonId,
    fired,
};

pub fn execute(co: *Company, cmd: Command) Error!Result {
    switch (cmd) {
        .hire => |h| return .{ .hired = try co.hire(h.name, h.role) },
        .fire => |id| {
            try co.fire(id);
            return .fired;
        },
    }
}

test "payroll is the sum of salaries and posts one transaction" {
    var co = Company.init(std.testing.allocator, .{ .funds = 10_000 });
    defer co.deinit();
    _ = try execute(&co, .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } });
    _ = try execute(&co, .{ .hire = .{ .name = "Clay", .role = .tech } });
    try std.testing.expectEqual(@as(CBills, 2_300), co.monthlyPayroll());
    try co.runPayroll();
    try std.testing.expectEqual(@as(CBills, 7_700), co.funds);
    try std.testing.expectEqual(@as(usize, 1), co.ledger.transactions.items.len);
    try std.testing.expectEqual(@as(CBills, -2_300), co.ledger.sumCategory(.payroll));
}

test "firing posts severance" {
    var co = Company.init(std.testing.allocator, .{ .funds = 10_000 });
    defer co.deinit();
    const r = try execute(&co, .{ .hire = .{ .name = "Lori", .role = .mekwarrior } });
    _ = try execute(&co, .{ .fire = r.hired });
    try std.testing.expectEqual(@as(CBills, 8_500), co.funds);
    try std.testing.expectEqual(@as(CBills, -1_500), co.ledger.sumCategory(.severance));
}

test "the ledger and the balance never disagree" {
    var co = Company.init(std.testing.allocator, .{ .funds = 10_000 });
    defer co.deinit();
    _ = try execute(&co, .{ .hire = .{ .name = "A", .role = .admin } });
    try co.runPayroll();
    try co.postTransaction(.{ .day = 0, .amount = 4_000, .category = .contract, .note = "advance" });
    try co.runPayroll();
    try std.testing.expectEqual(co.funds, co.starting_funds + co.ledger.balance());
}
