const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // zig build -Ddata=mods/hardcore  overlays data/tuning.zon
    const data_dir = b.option([]const u8, "data", "Directory overlaying data/tuning.zon");

    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    var tuning: std.Build.LazyPath = b.path("data/tuning.zon");
    if (data_dir) |dir| tuning = b.path(b.pathJoin(&.{ dir, "tuning.zon" }));
    mod.addAnonymousImport("tuning_zon", .{ .root_source_file = tuning });

    const exe = b.addExecutable(.{ .name = "overlay", .root_module = mod });
    b.installArtifact(exe);

    const run_step = b.step("run", "Print the live tuning table");
    run_step.dependOn(&b.addRunArtifact(exe).step);

    const tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Validate the tuning table");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
