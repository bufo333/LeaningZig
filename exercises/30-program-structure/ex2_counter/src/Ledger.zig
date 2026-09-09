//! Chapter 30, exercise 2: a file that is a struct.
//! This file has fields at the top level, so @import("Ledger.zig") IS the
//! type. By convention such files are named in CapitalCase.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

funds: i64,
day: u32 = 1,
log: std.ArrayList(i64) = .empty,

const Ledger = @This();

pub fn init(funds: i64) Ledger {
    return .{ .funds = funds };
}

pub fn deinit(self: *Ledger, gpa: std.mem.Allocator) void {
    self.log.deinit(gpa);
}

pub fn apply(self: *Ledger, gpa: std.mem.Allocator, delta: i64) !void {
    // TODO: implement this function.
    @panic("TODO");
}

pub fn nextDay(self: *Ledger) void {
    // TODO: implement this function.
    @panic("TODO");
}

test "Ledger is the file" {
    try std.testing.expect(@TypeOf(Ledger.init(0)) == Ledger);
}
