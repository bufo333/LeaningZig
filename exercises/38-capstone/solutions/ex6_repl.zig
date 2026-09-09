//! Chapter 38, stage 6: the REPL, with save and load.
//! Run with:  printf 'hire Grayson mekwarrior\nhire Clay tech\nadvance 31\nledger\nsave ledger.sav\nquit\n' | zig run ex6_repl.zig
//! Goal: read commands from stdin, run them through the pure core, print
//! results, and persist the whole company to a text file with std.Io.
//! Verbs: hire NAME ROLE, fire ID, advance N, people, ledger, log,
//! save FILE, load FILE, quit. Expected output for the command above:
//!   > hired Grayson as mekwarrior (id 1)
//!   > hired Clay as tech (id 2)
//!   > advanced 31 days to 3025-02-01, funds 47746
//!   > day 31  -2254  payroll  monthly payroll
//!   balance 47746
//!   > saved ledger.sav
//!   > bye

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

// ---------------------------------------------------------------------
// Everything above this line is the pure core: no io, no stdin, no files.
// Everything below is the edge: parsing text, printing, saving, loading.
// ---------------------------------------------------------------------

const ParseError = error{ UnknownVerb, MissingArgument, BadNumber, BadRole };

const ReplCommand = union(enum) {
    sim: Command,
    people,
    ledger,
    log,
    save: []const u8,
    load: []const u8,
    quit,
};

fn parseLine(line: []const u8) ParseError!ReplCommand {
    var it = std.mem.tokenizeScalar(u8, line, ' ');
    const verb = it.next() orelse return error.UnknownVerb;
    if (std.mem.eql(u8, verb, "hire")) {
        const name = it.next() orelse return error.MissingArgument;
        const role_text = it.next() orelse return error.MissingArgument;
        const role = std.meta.stringToEnum(Role, role_text) orelse return error.BadRole;
        return .{ .sim = .{ .hire = .{ .name = name, .role = role } } };
    } else if (std.mem.eql(u8, verb, "fire")) {
        const id_text = it.next() orelse return error.MissingArgument;
        const id = std.fmt.parseInt(u32, id_text, 10) catch return error.BadNumber;
        return .{ .sim = .{ .fire = @enumFromInt(id) } };
    } else if (std.mem.eql(u8, verb, "advance")) {
        const n_text = it.next() orelse return error.MissingArgument;
        const n = std.fmt.parseInt(u32, n_text, 10) catch return error.BadNumber;
        return .{ .sim = .{ .advance_days = n } };
    } else if (std.mem.eql(u8, verb, "people")) {
        return .people;
    } else if (std.mem.eql(u8, verb, "ledger")) {
        return .ledger;
    } else if (std.mem.eql(u8, verb, "log")) {
        return .log;
    } else if (std.mem.eql(u8, verb, "save")) {
        return .{ .save = it.next() orelse return error.MissingArgument };
    } else if (std.mem.eql(u8, verb, "load")) {
        return .{ .load = it.next() orelse return error.MissingArgument };
    } else if (std.mem.eql(u8, verb, "quit")) {
        return .quit;
    }
    return error.UnknownVerb;
}

/// Save format: one record per line, whitespace separated, notes last.
fn save(io: std.Io, co: *Company, path: []const u8) !void {
    var file = try std.Io.Dir.cwd().createFile(io, path, .{});
    defer file.close(io);
    var buf: [4096]u8 = undefined;
    var fw = file.writer(io, &buf);
    const w = &fw.interface;
    try w.print("smallledger 1\n", .{});
    try w.print("seed {d}\n", .{co.seed});
    try w.print("clock {d} {d} {d} {d}\n", .{ co.clock.day_index, co.clock.date.year, co.clock.date.month, co.clock.date.day });
    try w.print("funds {d} {d} {d}\n", .{ co.funds, co.starting_funds, co.next_id });
    for (co.rng.prngs, 0..) |prng, i| {
        try w.print("rng {d} {d} {d} {d} {d}\n", .{ i, prng.s[0], prng.s[1], prng.s[2], prng.s[3] });
    }
    for (co.people.items) |p| {
        try w.print("person {d} {s} {s} {d} {d}\n", .{ @intFromEnum(p.id), p.name, @tagName(p.role), p.hired_day, p.morale });
    }
    for (co.ledger.transactions.items) |t| {
        try w.print("txn {d} {d} {s} {s}\n", .{ t.day, t.amount, @tagName(t.category), t.note });
    }
    for (co.log.items) |line| try w.print("log {s}\n", .{line});
    try w.flush();
}

const LoadError = error{ BadFormat, OutOfMemory };

fn load(io: std.Io, gpa: std.mem.Allocator, path: []const u8) !Company {
    const text = try std.Io.Dir.cwd().readFileAlloc(io, path, gpa, .limited(1 << 24));
    defer gpa.free(text);

    var co = Company.init(gpa, .{});
    errdefer co.deinit();
    var lines = std.mem.splitScalar(u8, text, '\n');
    const header = lines.next() orelse return error.BadFormat;
    if (!std.mem.eql(u8, header, "smallledger 1")) return error.BadFormat;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const kind = it.next() orelse continue;
        if (std.mem.eql(u8, kind, "seed")) {
            co.seed = try num(u64, &it);
            co.rng = Rng.init(co.seed);
        } else if (std.mem.eql(u8, kind, "clock")) {
            co.clock.day_index = try num(u32, &it);
            co.clock.date = .{ .year = try num(u16, &it), .month = try num(u8, &it), .day = try num(u8, &it) };
        } else if (std.mem.eql(u8, kind, "funds")) {
            co.funds = try num(CBills, &it);
            co.starting_funds = try num(CBills, &it);
            co.next_id = try num(u32, &it);
        } else if (std.mem.eql(u8, kind, "rng")) {
            const i = try num(usize, &it);
            if (i >= Stream.count) return error.BadFormat;
            for (&co.rng.prngs[i].s) |*s| s.* = try num(u64, &it);
        } else if (std.mem.eql(u8, kind, "person")) {
            const id = try num(u32, &it);
            const name = it.next() orelse return error.BadFormat;
            const role = std.meta.stringToEnum(Role, it.next() orelse return error.BadFormat) orelse return error.BadFormat;
            const hired_day = try num(u32, &it);
            const morale = try num(i8, &it);
            try co.people.append(co.allocator(), .{
                .id = @enumFromInt(id),
                .name = try co.allocator().dupe(u8, name),
                .role = role,
                .hired_day = hired_day,
                .morale = morale,
            });
        } else if (std.mem.eql(u8, kind, "txn")) {
            const day = try num(u32, &it);
            const amount = try num(CBills, &it);
            const cat = std.meta.stringToEnum(Category, it.next() orelse return error.BadFormat) orelse return error.BadFormat;
            const note = try co.allocator().dupe(u8, it.rest());
            try co.ledger.post(co.allocator(), .{ .day = day, .amount = amount, .category = cat, .note = note });
        } else if (std.mem.eql(u8, kind, "log")) {
            try co.log.append(co.allocator(), try co.allocator().dupe(u8, it.rest()));
        } else {
            return error.BadFormat;
        }
    }
    return co;
}

fn num(comptime T: type, it: *std.mem.TokenIterator(u8, .scalar)) LoadError!T {
    const tok = it.next() orelse return error.BadFormat;
    return std.fmt.parseInt(T, tok, 10) catch error.BadFormat;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    var out_buf: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(io, &out_buf);
    const out = &stdout.interface;
    var in_buf: [1024]u8 = undefined;
    var stdin = std.Io.File.stdin().reader(io, &in_buf);

    var co = Company.init(gpa, .{});
    defer co.deinit();

    while (true) {
        try out.flush();
        const raw = try stdin.interface.takeDelimiter('\n') orelse break;
        const line = std.mem.trim(u8, raw, " \t\r\n");
        if (line.len == 0) continue;
        const cmd = parseLine(line) catch |e| {
            try out.print("> error: {s}\n", .{@errorName(e)});
            continue;
        };
        switch (cmd) {
            .sim => |c| {
                const result = execute(&co, c) catch |e| {
                    try out.print("> error: {s}\n", .{@errorName(e)});
                    continue;
                };
                switch (result) {
                    .hired => |id| try out.print("> hired {s} as {s} (id {d})\n", .{ c.hire.name, @tagName(c.hire.role), @intFromEnum(id) }),
                    .fired => try out.print("> fired {d}\n", .{@intFromEnum(c.fire)}),
                    .advanced => |n| try out.print("> advanced {d} days to {d}-{d:0>2}-{d:0>2}, funds {d}\n", .{
                        n, co.clock.date.year, co.clock.date.month, co.clock.date.day, co.funds,
                    }),
                }
            },
            .people => {
                for (co.people.items) |p| {
                    try out.print("> {d:>3}  {s:<10} {s:<10} morale {d:>3}  pay {d}\n", .{
                        @intFromEnum(p.id), p.name, @tagName(p.role), p.morale, p.monthlySalary(),
                    });
                }
                if (co.people.items.len == 0) try out.print("> nobody on the roster\n", .{});
            },
            .ledger => {
                for (co.ledger.transactions.items) |t| {
                    try out.print("> day {d}  {d}  {s}  {s}\n", .{ t.day, t.amount, @tagName(t.category), t.note });
                }
                try out.print("balance {d}\n", .{co.funds});
            },
            .log => {
                for (co.log.items) |l| try out.print("> {s}\n", .{l});
                if (co.log.items.len == 0) try out.print("> quiet so far\n", .{});
            },
            .save => |path| {
                save(io, &co, path) catch |e| {
                    try out.print("> save failed: {s}\n", .{@errorName(e)});
                    continue;
                };
                try out.print("> saved {s}\n", .{path});
            },
            .load => |path| {
                const loaded = load(io, gpa, path) catch |e| {
                    try out.print("> load failed: {s}\n", .{@errorName(e)});
                    continue;
                };
                co.deinit();
                co = loaded;
                try out.print("> loaded {s}: day {d}, {d} people, funds {d}\n", .{ path, co.clock.day_index, co.people.items.len, co.funds });
            },
            .quit => break,
        }
    }
    try out.print("> bye\n", .{});
    try out.flush();
}

test "save then load reproduces the hash" {
    const io = std.testing.io;
    const gpa = std.testing.allocator;
    var co = Company.init(gpa, .{ .seed = 9 });
    defer co.deinit();
    _ = try execute(&co, .{ .hire = .{ .name = "Grayson", .role = .mekwarrior } });
    _ = try execute(&co, .{ .advance_days = 60 });
    try save(io, &co, "test_roundtrip.sav");
    defer std.Io.Dir.cwd().deleteFile(io, "test_roundtrip.sav") catch {};
    var back = try load(io, gpa, "test_roundtrip.sav");
    defer back.deinit();
    try std.testing.expectEqual(co.hash(), back.hash());
    // and the two continue identically, because the RNG state was saved
    _ = try execute(&co, .{ .advance_days = 100 });
    _ = try execute(&back, .{ .advance_days = 100 });
    try std.testing.expectEqual(co.hash(), back.hash());
}

test "parseLine" {
    const c = try parseLine("hire Grayson mekwarrior");
    try std.testing.expectEqualStrings("Grayson", c.sim.hire.name);
    try std.testing.expectError(error.BadRole, parseLine("hire X pirate"));
    try std.testing.expectError(error.UnknownVerb, parseLine("dance"));
    try std.testing.expectError(error.BadNumber, parseLine("advance ten"));
}
