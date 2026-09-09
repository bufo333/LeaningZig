//! Chapter 14, exercise 4: a tiny stack-machine interpreter (challenge).
//! Run with:  zig test ex4_interpreter.zig
//! Goal: make every test pass without changing the tests.
//! This starter does not compile until you fill in the TODO body.
const std = @import("std");

/// One instruction for a stack machine.
const Op = union(enum) {
    push: i64,
    add,
    sub,
    mul,
    dup,
    swap,
    jump_if_zero: usize, // pop; if zero, jump to this instruction index
    halt,
};

const Error = error{ StackUnderflow, StackOverflow, BadJump, NoHalt };

const Machine = struct {
    stack: [16]i64 = undefined,
    sp: usize = 0, // number of values on the stack
    pc: usize = 0, // index of the next instruction
    steps: usize = 0,

    fn push(self: *Machine, v: i64) Error!void {
        if (self.sp == self.stack.len) return error.StackOverflow;
        self.stack[self.sp] = v;
        self.sp += 1;
    }

    fn pop(self: *Machine) Error!i64 {
        if (self.sp == 0) return error.StackUnderflow;
        self.sp -= 1;
        return self.stack[self.sp];
    }

    /// Run until halt. Returns the top of the stack (or 0 if empty).
    fn run(self: *Machine, program: []const Op) Error!i64 {
        while (self.pc < program.len) {
            const op = program[self.pc];
            self.pc += 1;
            self.steps += 1;
            if (self.steps > 10_000) return error.NoHalt;
            _ = op;
            // TODO: one exhaustive switch over `op`.
            //   push: push the payload.   add/mul: pop two, push the result.
            //   sub: pop b then a, push a - b.   dup: pop a, push a twice.
            //   swap: pop b then a, push b then a.
            //   jump_if_zero: BadJump if target > program.len; pop; if zero, pc = target.
            //   halt: return the top of the stack, or 0 if the stack is empty.
        }
        return error.NoHalt;
    }
};

fn runProgram(program: []const Op) Error!i64 {
    var m = Machine{};
    return m.run(program);
}

test "arithmetic" {
    // (2 + 3) * 4 - 1
    const prog = [_]Op{
        .{ .push = 2 }, .{ .push = 3 }, .add, .{ .push = 4 }, .mul, .{ .push = 1 }, .sub, .halt,
    };
    try std.testing.expectEqual(@as(i64, 19), try runProgram(&prog));
}

test "dup and swap" {
    const prog = [_]Op{ .{ .push = 7 }, .dup, .mul, .{ .push = 100 }, .swap, .sub, .halt };
    // swap turns [49, 100] into [100, 49], so sub computes 100 - 49
    try std.testing.expectEqual(@as(i64, 100 - 49), try runProgram(&prog));
}

test "errors" {
    try std.testing.expectError(error.StackUnderflow, runProgram(&[_]Op{ .add, .halt }));
    try std.testing.expectError(error.NoHalt, runProgram(&[_]Op{.{ .push = 1 }}));
    const bad = [_]Op{ .{ .push = 0 }, .{ .jump_if_zero = 99 }, .halt };
    try std.testing.expectError(error.BadJump, runProgram(&bad));
}

test "countdown loop" {
    // n = 5; while (n != 0) n -= 1; leaves 0 on the stack.
    const prog = [_]Op{
        .{ .push = 5 }, // 0
        .dup, // 1: copy n so the test does not consume it
        .{ .jump_if_zero = 7 }, // 2: if n == 0 go to halt
        .{ .push = 1 }, // 3
        .sub, // 4: n = n - 1
        .{ .push = 0 }, // 5
        .{ .jump_if_zero = 1 }, // 6: always jumps (0 is zero)
        .halt, // 7
    };
    var m = Machine{};
    try std.testing.expectEqual(@as(i64, 0), try m.run(&prog));
    try std.testing.expect(m.steps < 100);
}
