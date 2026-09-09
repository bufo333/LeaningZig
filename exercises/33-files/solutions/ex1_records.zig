//! Chapter 33, exercise 1: save and load a list of records.
//! Run with:  zig test ex1_records.zig
//! Goal: make every test pass without changing the tests.
const std = @import("std");

pub const Pilot = struct { name: []const u8, gunnery: u8, piloting: u8 };

/// Write one line per pilot: "name,gunnery,piloting\n".
pub fn save(dir: std.Io.Dir, io: std.Io, path: []const u8, pilots: []const Pilot) !void {
    var file = try dir.createFile(io, path, .{});
    defer file.close(io);
    var buf: [512]u8 = undefined;
    var fw = file.writer(io, &buf);
    const w = &fw.interface;
    for (pilots) |p| try w.print("{s},{d},{d}\n", .{ p.name, p.gunnery, p.piloting });
    try w.flush();
}

/// Read the file back. Names are copied into `gpa`; the caller frees them
/// with `freePilots`. A missing file yields an empty list, not an error.
pub fn load(dir: std.Io.Dir, io: std.Io, gpa: std.mem.Allocator, path: []const u8) ![]Pilot {
    var file = dir.openFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return try gpa.alloc(Pilot, 0),
        else => return err,
    };
    defer file.close(io);
    var buf: [512]u8 = undefined;
    var fr = file.reader(io, &buf);
    const r = &fr.interface;
    var out: std.ArrayList(Pilot) = .empty;
    errdefer {
        // On any failure below, give back every name we already copied,
        // then the list itself. One block, so the order is explicit.
        for (out.items) |p| gpa.free(p.name);
        out.deinit(gpa);
    }
    while (try r.takeDelimiter('\n')) |line| {
        if (line.len == 0) continue;
        var it = std.mem.splitScalar(u8, line, ',');
        const name = it.next() orelse return error.BadRecord;
        const g = it.next() orelse return error.BadRecord;
        const p = it.next() orelse return error.BadRecord;
        try out.append(gpa, .{
            .name = try gpa.dupe(u8, name),
            .gunnery = try std.fmt.parseInt(u8, g, 10),
            .piloting = try std.fmt.parseInt(u8, p, 10),
        });
    }
    return out.toOwnedSlice(gpa);
}

pub fn freePilots(gpa: std.mem.Allocator, pilots: []Pilot) void {
    for (pilots) |p| gpa.free(p.name);
    gpa.free(pilots);
}

test "round trip" {
    const io = std.testing.io;
    const gpa = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const roster = [_]Pilot{
        .{ .name = "Kell", .gunnery = 3, .piloting = 4 },
        .{ .name = "Ana Ruiz", .gunnery = 5, .piloting = 5 },
    };
    try save(tmp.dir, io, "roster.csv", &roster);
    const back = try load(tmp.dir, io, gpa, "roster.csv");
    defer freePilots(gpa, back);
    try std.testing.expectEqual(@as(usize, 2), back.len);
    try std.testing.expectEqualStrings("Ana Ruiz", back[1].name);
    try std.testing.expectEqual(@as(u8, 3), back[0].gunnery);
}

test "missing file is an empty roster" {
    const gpa = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const back = try load(tmp.dir, std.testing.io, gpa, "nothing.csv");
    defer freePilots(gpa, back);
    try std.testing.expectEqual(@as(usize, 0), back.len);
}

test "a broken line is an error and leaks nothing" {
    const io = std.testing.io;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.writeFile(io, .{ .sub_path = "bad.csv", .data = "Kell,3,4\nAna,5\n" });
    try std.testing.expectError(error.BadRecord, load(tmp.dir, io, std.testing.allocator, "bad.csv"));
}
