//! Chapter 25, exercise 2: a sieve of Eratosthenes at compile time.
//! Run with:  zig test ex2_sieve.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

const limit = 1000;

/// is_prime[n] is true when n is prime, for n < limit. Built by the compiler.
const is_prime: [limit]bool = blk: {
    @setEvalBranchQuota(20_000); // the nested loops need more than the default
    var t: [limit]bool = @splat(true);
    t[0] = false;
    t[1] = false;
    var i: usize = 2;
    while (i * i < limit) : (i += 1) {
        if (!t[i]) continue;
        var j = i * i;
        while (j < limit) : (j += i) t[j] = false;
    }
    break :blk t;
};

/// How many primes are below `n` (n <= limit)?
fn primesBelow(n: usize) usize {
    var count: usize = 0;
    for (is_prime[0..n]) |p| {
        if (p) count += 1;
    }
    return count;
}

/// Computed once, at compile time, from the table. The loop runs `limit` times,
/// which is over the default quota, so raise it for this evaluation.
const prime_count = blk: {
    @setEvalBranchQuota(2000);
    break :blk primesBelow(limit);
};

test "small primes" {
    try std.testing.expect(is_prime[2]);
    try std.testing.expect(is_prime[97]);
    try std.testing.expect(!is_prime[1]);
    try std.testing.expect(!is_prime[91]); // 7 * 13
}

test "counts" {
    try std.testing.expectEqual(@as(usize, 25), primesBelow(100));
    try std.testing.expectEqual(@as(usize, 168), prime_count);
}

test "prime_count is usable as an array length" {
    const arr: [prime_count]u8 = undefined;
    try std.testing.expectEqual(@as(usize, 168), arr.len);
}
