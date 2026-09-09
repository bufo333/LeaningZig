const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const difficulty = b.option(enum { easy, normal, hard }, "difficulty", "Starting difficulty") orelse .normal;
    const start_funds = b.option(u32, "funds", "Starting C-bills") orelse 1_000_000;
    const cheats = b.option(bool, "cheats", "Enable cheat commands") orelse false;

    const opts = b.addOptions();
    opts.addOption([]const u8, "difficulty", @tagName(difficulty));
    opts.addOption(u32, "start_funds", start_funds);
    opts.addOption(bool, "cheats", cheats);

    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    mod.addOptions("build_options", opts);

    const exe = b.addExecutable(.{ .name = "options", .root_module = mod });
    b.installArtifact(exe);
    b.step("run", "Print the baked-in settings").dependOn(&b.addRunArtifact(exe).step);

    const tests = b.addTest(.{ .root_module = mod });
    b.step("test", "Run tests").dependOn(&b.addRunArtifact(tests).step);
}
