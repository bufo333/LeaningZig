//! Chapter 05, exercise 3: a readiness check with and/or/not.
//! Run with:  zig test ex3_ready.zig
//! Goal: make every test pass without changing the tests.
//! Write each body as a single boolean expression (no if statements needed
//! for canDeploy; an if expression is fine for moraleLabel).
const std = @import("std");

/// A unit may deploy when it has a pilot, is not destroyed, and either has
/// at least 30 armor or is being sent on a milk run.
fn canDeploy(has_pilot: bool, destroyed: bool, armor: u8, milk_run: bool) bool {
    _ = has_pilot;
    _ = destroyed;
    _ = armor;
    _ = milk_run;
    return false; // TODO
}

/// Morale label: "high" at 70 or more, "low" below 30, otherwise "steady".
fn moraleLabel(morale: u8) []const u8 {
    _ = morale;
    return "TODO";
}

test "canDeploy" {
    try std.testing.expect(canDeploy(true, false, 50, false));
    try std.testing.expect(canDeploy(true, false, 10, true));
    try std.testing.expect(!canDeploy(true, false, 10, false));
    try std.testing.expect(!canDeploy(false, false, 100, true));
    try std.testing.expect(!canDeploy(true, true, 100, true));
}

test "moraleLabel" {
    try std.testing.expectEqualStrings("high", moraleLabel(70));
    try std.testing.expectEqualStrings("steady", moraleLabel(69));
    try std.testing.expectEqualStrings("steady", moraleLabel(30));
    try std.testing.expectEqualStrings("low", moraleLabel(29));
}
