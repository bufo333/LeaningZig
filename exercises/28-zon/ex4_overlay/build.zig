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
    // TODO: pick data/tuning.zon, or <data_dir>/tuning.zon when -Ddata is given,
    // and bind it to the import name "tuning_zon" with mod.addAnonymousImport.
    _ = data_dir;

    const exe = b.addExecutable(.{ .name = "overlay", .root_module = mod });
    b.installArtifact(exe);

    const run_step = b.step("run", "Print the live tuning table");
    run_step.dependOn(&b.addRunArtifact(exe).step);

    const tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Validate the tuning table");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
