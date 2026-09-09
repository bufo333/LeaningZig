//! Chapter 38, stage 5: a seeded RNG and a 2d6 morale event.
//! Run with:  zig test ex5_events.zig
//! Goal: add a named-stream Rng seeded from Options, an events phase in
//! advanceDay that rolls 2d6 for morale, a log, and a `hash` for the
//! golden-master test.

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

pub const Stream = enum(u8) {
    events,
    market,

    const count = @typeInfo(Stream).@"enum".fields.len;
};

/// One generator per subsystem, all derived from a single seed.
pub const Rng = struct {
    prngs: [Stream.count]std.Random.DefaultPrng,

    pub fn init(seed: u64) Rng {
        var self: Rng = undefined;
        for (&self.prngs, 0..) |*prng, i| {
            prng.* = std.Random.DefaultPrng.init(seed ^ (0x9E3779B97F4A7C15 *% (i + 1)));
        }
        return self;
    }

    pub fn roll2d6(self: *Rng, stream: Stream) u8 {
        const r = self.prngs[@intFromEnum(stream)].random();
        return r.intRangeAtMost(u8, 1, 6) + r.intRangeAtMost(u8, 1, 6);
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
    seed: u64,
    rng: Rng,
    log: std.ArrayList([]const u8) = .empty,

    pub const Options = struct {
        funds: CBills = 50_000,
        seed: u64 = 3025,
    };

    pub fn init(gpa: std.mem.Allocator, opts: Options) Company {
        return .{
            .arena = std.heap.ArenaAllocator.init(gpa),
            .funds = opts.funds,
            .starting_funds = opts.funds,
            .seed = opts.seed,
            .rng = Rng.init(opts.seed),
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

    pub fn logf(self: *Company, comptime fmt: []const u8, args: anytype) Error!void {
        const line = try std.fmt.allocPrint(self.allocator(), fmt, args);
        try self.log.append(self.allocator(), line);
    }

    /// A 64-bit fingerprint of everything that matters. Two companies with
    /// the same seed and the same commands must produce the same hash.
    pub fn hash(self: *Company) u64 {
        var h = std.hash.Wyhash.init(0);
        h.update(std.mem.asBytes(&self.clock.day_index));
        h.update(std.mem.asBytes(&self.funds));
        for (self.people.items) |p| {
            h.update(std.mem.asBytes(&p.id));
            h.update(p.name);
            h.update(std.mem.asBytes(&p.morale));
            h.update(std.mem.asBytes(&p.hired_day));
        }
        const n: u64 = self.ledger.transactions.items.len;
        h.update(std.mem.asBytes(&n));
        return h.final();
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

/// One campaign day, in a fixed order of phases: events, then finances.
pub fn advanceDay(co: *Company) Error!void {
    co.clock.advance();
    try runEvents(co);
    if (co.clock.date.isPayday()) try co.runPayroll();
}

/// The morale event: 2d6 on the events stream every day. Snake eyes and
/// boxcars are the only rolls that do anything, so most days are quiet.
fn runEvents(co: *Company) Error!void {
    const roll = co.rng.roll2d6(.events);
    switch (roll) {
        2 => {
            for (co.people.items) |*p| p.morale = @max(p.morale - 1, -10);
            try co.logf("day {d}: grumbling in the barracks (rolled 2), morale -1", .{co.clock.day_index});
        },
        12 => {
            for (co.people.items) |*p| p.morale = @min(p.morale + 1, 10);
            try co.logf("day {d}: a good day (rolled 12), morale +1", .{co.clock.day_index});
        },
        else => {},
    }
}

test "golden master: same seed + same script = same hash" {
    const script = [_]Command{
        .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } },
        .{ .hire = .{ .name = "Lori", .role = .mekwarrior } },
        .{ .hire = .{ .name = "Clay", .role = .tech } },
        .{ .advance_days = 45 },
        .{ .fire = @enumFromInt(2) },
        .{ .advance_days = 45 },
    };
    var hashes: [2]u64 = undefined;
    for (&hashes) |*out| {
        var co = Company.init(std.testing.allocator, .{ .seed = 42 });
        defer co.deinit();
        for (script) |cmd| _ = try execute(&co, cmd);
        out.* = co.hash();
    }
    try std.testing.expectEqual(hashes[0], hashes[1]);
}

test "a different seed gives a different history" {
    var a = Company.init(std.testing.allocator, .{ .seed = 1 });
    defer a.deinit();
    var b = Company.init(std.testing.allocator, .{ .seed = 2 });
    defer b.deinit();
    for ([_]*Company{ &a, &b }) |co| {
        _ = try execute(co, .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } });
        _ = try execute(co, .{ .advance_days = 400 });
    }
    try std.testing.expect(a.hash() != b.hash());
    try std.testing.expect(a.log.items.len > 0);
}

test "morale stays within -10..10 and moves pay" {
    var co = Company.init(std.testing.allocator, .{ .seed = 7, .funds = 1_000_000 });
    defer co.deinit();
    const r = try execute(&co, .{ .hire = .{ .name = "Clay", .role = .tech } });
    _ = try execute(&co, .{ .advance_days = 2000 });
    const p = co.find(r.hired).?;
    try std.testing.expect(p.morale >= -10 and p.morale <= 10);
    const expected = applyBp(800, 10_000 + @as(Bp, p.morale) * 200);
    try std.testing.expectEqual(expected, p.monthlySalary());
}
