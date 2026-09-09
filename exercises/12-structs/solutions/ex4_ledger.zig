//! Chapter 12, exercise 4: a tiny ledger (challenge).
//! Run with:  zig test ex4_ledger.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const Entry = struct {
    day: u32,
    label: []const u8,
    amount: i64, // positive = income, negative = expense
};

const Ledger = struct {
    entries: [8]Entry = undefined,
    len: usize = 0,
    opening: i64,

    const Self = @This();

    /// Record an entry. Returns error.Full when the fixed array is used up.
    pub fn post(self: *Self, day: u32, label: []const u8, amount: i64) !void {
        if (self.len == self.entries.len) return error.Full;
        self.entries[self.len] = .{ .day = day, .label = label, .amount = amount };
        self.len += 1;
    }

    pub fn balance(self: Self) i64 {
        var b = self.opening;
        for (self.entries[0..self.len]) |e| b += e.amount;
        return b;
    }

    /// Balance as it stood at the end of `day`.
    pub fn balanceOn(self: Self, day: u32) i64 {
        var b = self.opening;
        for (self.entries[0..self.len]) |e| {
            if (e.day <= day) b += e.amount;
        }
        return b;
    }

    /// The largest single expense (most negative amount), or null.
    pub fn biggestExpense(self: *const Self) ?Entry {
        var best: ?Entry = null;
        for (self.entries[0..self.len]) |e| {
            if (e.amount >= 0) continue;
            if (best == null or e.amount < best.?.amount) best = e;
        }
        return best;
    }
};

test "post and balance" {
    var l = Ledger{ .opening = 1_000_000 };
    try l.post(1, "contract advance", 250_000);
    try l.post(1, "salaries", -60_000);
    try l.post(15, "spare parts", -12_500);
    try std.testing.expectEqual(@as(i64, 1_177_500), l.balance());
    try std.testing.expectEqual(@as(i64, 1_190_000), l.balanceOn(1));
    try std.testing.expectEqual(@as(i64, 1_000_000), l.balanceOn(0));
}

test "biggest expense" {
    var l = Ledger{ .opening = 0 };
    try std.testing.expect(l.biggestExpense() == null);
    try l.post(1, "income", 500);
    try l.post(2, "salaries", -60_000);
    try l.post(3, "repairs", -75_000);
    try std.testing.expectEqualStrings("repairs", l.biggestExpense().?.label);
}

test "full ledger" {
    var l = Ledger{ .opening = 0 };
    var i: u32 = 0;
    while (i < 8) : (i += 1) try l.post(i, "x", 1);
    try std.testing.expectError(error.Full, l.post(9, "one too many", 1));
    try std.testing.expectEqual(@as(i64, 8), l.balance());
}
