const std = @import("std");
const Target = std.Target;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    var target = default_target(.wasm32, .freestanding);
    target.cpu.features = std.Target.wasm.featureSet(&.{ .atomics, .bulk_memory, .mutable_globals });

    const threads = b.addModule("threads", .{
        .source_file = .{ .path = "js-threads/src/main.zig" },
    });

    const exe = b.addSharedLibrary(.{
        .name = "js-threads-example",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = std.zig.CrossTarget.fromTarget(target),
        .optimize = optimize,
    });
    exe.addModule("threads", threads);
    exe.import_memory = true;
    exe.shared_memory = true;
    exe.initial_memory = 17 * 65536;
    exe.max_memory = 24 * 65536;
    exe.linkage = .dynamic;
    exe.rdynamic = true;

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = std.zig.CrossTarget.fromTarget(target),
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

fn default_target(arch: Target.Cpu.Arch, os_tag: Target.Os.Tag) Target {
    const os = os_tag.defaultVersionRange(arch);
    return Target{
        .cpu = Target.Cpu.baseline(arch),
        .abi = Target.Abi.default(arch, os),
        .os = os,
        .ofmt = Target.ObjectFormat.default(os_tag, arch),
    };
}
