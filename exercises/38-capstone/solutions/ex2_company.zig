//! Chapter 38, stage 2: a Company and its commands.
//! Run with:  zig test ex2_company.zig
//! Goal: add a Company that owns its people through an arena, and a
//! tagged-union Command with an `execute` function that returns errors.

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

pub const Error = error{ UnknownPerson, EmptyName, OutOfMemory };

pub const Company = struct {
    arena: std.heap.ArenaAllocator,
    people: std.ArrayList(Person) = .empty,
    next_id: u32 = 1,
    day: u32 = 0,
    funds: CBills,

    pub const Options = struct {
        funds: CBills = 50_000,
    };

    pub fn init(gpa: std.mem.Allocator, opts: Options) Company {
        return .{
            .arena = std.heap.ArenaAllocator.init(gpa),
            .funds = opts.funds,
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
                _ = self.people.orderedRemove(i);
                return;
            }
        }
        return error.UnknownPerson;
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
