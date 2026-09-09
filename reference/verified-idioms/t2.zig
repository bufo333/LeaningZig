const std = @import("std");
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var dir = std.Io.Dir.cwd();
    var f = try dir.createFile(io, "probe_out.txt", .{});
    var wb: [256]u8 = undefined;
    var w = f.writer(io, &wb);
    try w.interface.print("line {d}\n", .{1});
    try w.interface.flush();
    f.close(io);
    const data = try dir.readFileAlloc(io, "probe_out.txt", init.gpa, .limited(1 << 20));
    defer init.gpa.free(data);
    std.debug.print("read back: {s}", .{data});
    const now = std.Io.Clock.now(.real, io);
    std.debug.print("now: {any}\n", .{now});
}
