const std = @import("std");
pub fn cbills(n: i64) i64 {
    return n * 100;
}
test "money" {
    try std.testing.expectEqual(@as(i64, 700), cbills(7));
}
