//! Chapter 17, exercise 3: begin / commit / rollback with errdefer.
//! Run with:  zig test ex3_transaction.zig
//! Goal: make every test pass without changing the tests.
//! (Starter: the TODO bodies panic until you replace them.)
const std = @import("std");

const Ledger = struct {
    funds: i64,
    snapshot: i64 = 0,
    in_transaction: bool = false,
    rollbacks: u32 = 0,

    fn begin(self: *Ledger) void {
        self.snapshot = self.funds;
        self.in_transaction = true;
    }
    fn commit(self: *Ledger) void {
        self.in_transaction = false;
    }
    fn rollback(self: *Ledger) void {
        self.funds = self.snapshot;
        self.in_transaction = false;
        self.rollbacks += 1;
    }

    fn debit(self: *Ledger, amount: i64) !void {
        if (amount > self.funds) return error.InsufficientTreasury;
        self.funds -= amount;
    }

    /// Pay every bill in `bills` as one transaction: either all of them
    /// are paid, or none are. Use begin, errdefer rollback, commit.
    fn payAll(self: *Ledger, bills: []const i64) !void {
        // TODO: implement
        @panic("TODO");
    }
};

test "all bills paid" {
    var l = Ledger{ .funds = 100 };
    try l.payAll(&.{ 10, 20, 30 });
    try std.testing.expectEqual(@as(i64, 40), l.funds);
    try std.testing.expect(!l.in_transaction);
    try std.testing.expectEqual(@as(u32, 0), l.rollbacks);
}

test "one bad bill rolls back the rest" {
    var l = Ledger{ .funds = 100 };
    try std.testing.expectError(error.InsufficientTreasury, l.payAll(&.{ 10, 20, 500, 5 }));
    try std.testing.expectEqual(@as(i64, 100), l.funds);
    try std.testing.expect(!l.in_transaction);
    try std.testing.expectEqual(@as(u32, 1), l.rollbacks);
}
