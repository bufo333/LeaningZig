//! Chapter 30, exercise 1: one program, several files.
//! Run with:  zig build run   and   zig build test   (inside ex1_split/)
//! Goal: split the roster logic into domain/types.zig, domain/pilot.zig and
//!       roster.zig so that main.zig only wires them together.
const std = @import("std");
const types = @import("domain/types.zig");
const pilot = @import("domain/pilot.zig");
const roster = @import("roster.zig");

pub fn main() void {
    var r = roster.Roster{};
    r.add(pilot.Pilot.init("Kell", 3, 4));
    r.add(pilot.Pilot.init("Ana", 5, 5));
    r.add(pilot.Pilot.init("Bo", 2, 3));
    std.debug.print("{d} pilots, best is {s} (skill {d})\n", .{ r.count, r.best().?.name, r.best().?.skill() });
    const id: types.PersonId = @enumFromInt(1);
    std.debug.print("pilot #{d} is {s}\n", .{ @intFromEnum(id), r.get(id).?.name });
}

test {
    // Pull every file's tests into this test binary.
    std.testing.refAllDecls(@This());
    _ = types;
    _ = pilot;
    _ = roster;
}
