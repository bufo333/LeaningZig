const std = @import("std");
pub fn main(init: std.process.Init) !void {
    var buf: [1024]u8 = undefined;
    var w = std.Io.File.stdout().writer(init.io, &buf);
    const out = &w.interface;
    try out.print("Hello from stdout, {d}\n", .{42});
    try out.flush();
}
