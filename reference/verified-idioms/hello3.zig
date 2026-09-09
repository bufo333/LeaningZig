const std = @import("std");
pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(gpa);
    try list.append(gpa, 5);
    try list.append(gpa, 7);
    var it = std.process.Args.Iterator.init(init.minimal.args);
    _ = it.next();
    while (it.next()) |a| std.debug.print("arg {s}\n", .{a});
    std.debug.print("sum {d}\n", .{list.items[0] + list.items[1]});
    // stdin read
    var rbuf: [256]u8 = undefined;
    var r = std.Io.File.stdin().reader(init.io, &rbuf);
    const line = r.interface.takeDelimiter('\n') catch |e| blk: { std.debug.print("err {s}\n", .{@errorName(e)}); break :blk null; };
    if (line) |l| std.debug.print("you typed: {s}\n", .{l});
}
