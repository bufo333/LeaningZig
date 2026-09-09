const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{ .name = "steps", .root_module = mod });
    b.installArtifact(exe);

    // A "run" step that forwards `zig build run -- args`.
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run the program").dependOn(&run_cmd.step);

    // A "demo" step that always runs the program with fixed arguments.
    const demo_cmd = b.addRunArtifact(exe);
    demo_cmd.addArgs(&.{ "alpha", "beta", "gamma" });
    b.step("demo", "Run with three fixed arguments").dependOn(&demo_cmd.step);

    // A "fmt" step: zig fmt --check over src/.
    const fmt = b.addFmt(.{ .paths = &.{"src"}, .check = true });
    b.step("fmt", "Check formatting").dependOn(&fmt.step);

    // "test" depends on tests AND on the format check.
    const tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Run tests and the format check");
    test_step.dependOn(&b.addRunArtifact(tests).step);
    test_step.dependOn(&fmt.step);
}
