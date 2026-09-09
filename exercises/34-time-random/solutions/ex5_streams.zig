//! Chapter 34, exercise 5: named random streams.
//! Run with:  zig test ex5_streams.zig
//! Goal: implement `Rng.init` so every stream gets its own generator
//! derived from the seed, and make the tests pass.

const std = @import("std");

pub const Stream = enum(u8) {
    market,
    battle,
    events,

    const count = @typeInfo(Stream).@"enum".fields.len;
};

pub const Rng = struct {
    prngs: [Stream.count]std.Random.DefaultPrng,

    pub fn init(seed: u64) Rng {
        var self: Rng = undefined;
        for (&self.prngs, 0..) |*prng, i| {
            prng.* = std.Random.DefaultPrng.init(seed ^ (0x9E3779B97F4A7C15 *% (i + 1)));
        }
        return self;
    }

    pub fn random(self: *Rng, stream: Stream) std.Random {
        return self.prngs[@intFromEnum(stream)].random();
    }

    pub fn roll2d6(self: *Rng, stream: Stream) u8 {
        const r = self.random(stream);
        return r.intRangeAtMost(u8, 1, 6) + r.intRangeAtMost(u8, 1, 6);
    }
};

test "streams are independent" {
    var a = Rng.init(42);
    var b = Rng.init(42);
    for (0..1000) |_| _ = a.roll2d6(.market);
    for (0..10) |_| try std.testing.expectEqual(b.roll2d6(.battle), a.roll2d6(.battle));
}

test "streams differ from each other" {
    var r = Rng.init(7);
    var same: usize = 0;
    for (0..50) |_| {
        if (r.roll2d6(.market) == r.roll2d6(.events)) same += 1;
    }
    try std.testing.expect(same < 50);
}

test "2d6 stays in range" {
    var r = Rng.init(7);
    for (0..1000) |_| {
        const v = r.roll2d6(.events);
        try std.testing.expect(v >= 2 and v <= 12);
    }
}
