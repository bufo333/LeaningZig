const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // The library module, importable as "dice".
    const dice = b.addModule("dice", .{
        .root_source_file = b.path("lib/dice.zig"),
        .target = target,
    });

    // The executable imports it.
    const exe = b.addExecutable(.{
        .name = "roll",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "dice", .module = dice }},
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Roll some dice").dependOn(&run_cmd.step);

    const lib_tests = b.addTest(.{ .root_module = dice });
    const exe_tests = b.addTest(.{ .root_module = exe.root_module });
    const test_step = b.step("test", "Run tests in both modules");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);
    test_step.dependOn(&b.addRunArtifact(exe_tests).step);
}
