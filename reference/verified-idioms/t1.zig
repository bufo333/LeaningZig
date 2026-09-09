const std = @import("std");
fn add(a: i32, b: i32) i32 { return a + b; }
test "add" { try std.testing.expectEqual(@as(i32, 5), add(2, 3)); }
test "map" {
    var m: std.AutoHashMapUnmanaged(u32, u32) = .empty;
    defer m.deinit(std.testing.allocator);
    try m.put(std.testing.allocator, 1, 2);
    try std.testing.expectEqual(@as(?u32, 2), m.get(1));
    var sm: std.StringHashMapUnmanaged(u32) = .empty;
    defer sm.deinit(std.testing.allocator);
    try sm.put(std.testing.allocator, "a", 1);
    const s = try std.fmt.allocPrint(std.testing.allocator, "{d}-{s}", .{ 1, "x" });
    defer std.testing.allocator.free(s);
    try std.testing.expectEqualStrings("1-x", s);
    const n = try std.fmt.parseInt(i32, "-12", 10);
    try std.testing.expectEqual(@as(i32, -12), n);
    var it = std.mem.tokenizeScalar(u8, "a b  c", ' ');
    var c: usize = 0;
    while (it.next()) |_| c += 1;
    try std.testing.expectEqual(@as(usize, 3), c);
    const f: f64 = 1.5;
    std.debug.print("float {d:.2} {e}\n", .{ f, f });
    const sorted = [_]u8{ 3, 1, 2 };
    var arr = sorted;
    std.mem.sort(u8, &arr, {}, std.sort.asc(u8));
    try std.testing.expectEqual(@as(u8, 1), arr[0]);
    var prng = std.Random.DefaultPrng.init(1);
    const r = prng.random().intRangeAtMost(u8, 1, 6);
    try std.testing.expect(r >= 1 and r <= 6);
}
