# Zig 0.16 Build System Recipes

Verified build.zig snippets for the common cases. SKILL.md has the minimal
`addExecutable` template; this file goes past it: tests, options, deps,
translate-c, libraries, cross-compile.

For anything not covered here:

- Full tutorial (authoritative, curated): https://ziglang.org/learn/build-system/
- API ground truth: `$(zig env | awk -F'"' '/\.std_dir/ {print $2}')/Build.zig`
  and the siblings under `Build/Step/`.

## Test step: `zig build test`

`addTest` produces a test binary; you still have to schedule it to run via
`addRunArtifact` and hang it off a named step. `zig build test` then runs it.

```zig
const exe_mod = b.createModule(.{
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
});

const tests = b.addTest(.{
    .name = "unit",
    .root_module = exe_mod,
});

const run_tests = b.addRunArtifact(tests);
const test_step = b.step("test", "Run unit tests");
test_step.dependOn(&run_tests.step);
```

`filters` on `addTest` takes a slice of test-name substrings and matches if
any entry is a substring. Useful for `zig build test -- -Dfilter=...` style
gating.

## Run step: `zig build run`

Mirror of the test pattern. `addRunArtifact` takes the exe, and the named
step depends on the run step.

```zig
const run_exe = b.addRunArtifact(exe);
run_exe.step.dependOn(b.getInstallStep()); // run the installed copy
if (b.args) |args| run_exe.addArgs(args);   // forward: zig build run -- a b c

const run_step = b.step("run", "Run the app");
run_step.dependOn(&run_exe.step);
```

## User options: `-Dflag=...`

`b.option(T, name, description)` reads `-D` flags from the command line.
Feed a struct of options into the compilation with `Module.addOptions`,
then `@import("build_options")` from source.

```zig
const verbose = b.option(bool, "verbose", "extra logging") orelse false;
const max_items = b.option(u32, "max-items", "cap on input") orelse 1024;

const options = b.addOptions();
options.addOption(bool, "verbose", verbose);
options.addOption(u32, "max_items", max_items);

exe.root_module.addOptions("build_options", options);
```

Source side:

```zig
const build_options = @import("build_options");
if (build_options.verbose) { ... }
const cap = build_options.max_items;
```

## Dependency from build.zig.zon

`build.zig.zon` declares the dep; `build.zig` pulls the module out and
imports it into a target's root module.

`build.zig.zon`:

```zig
.{
    .name = .myapp,
    .version = "0.0.0",
    .fingerprint = 0x0, // run `zig init` to generate
    .minimum_zig_version = "0.16.0",
    .dependencies = .{
        .mylib = .{
            .url = "https://example.com/mylib-0.1.0.tar.gz",
            .hash = "1220...", // set by `zig fetch --save`
        },
    },
    .paths = .{""},
}
```

`build.zig`:

```zig
const mylib = b.dependency("mylib", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("mylib", mylib.module("mylib"));
```

Add with `zig fetch --save <url>`; it fills `hash` for you.

## Linking C headers with `addTranslateC`

Replaces the deprecated `@cImport`. The generated module is imported by name
from source with `@import("c")`.

```zig
const c = b.addTranslateC(.{
    .root_source_file = b.path("src/includes.h"),
    .target = target,
    .optimize = optimize,
});
c.addIncludePath(b.path("vendor/libfoo/include"));
c.defineCMacro("LIBFOO_STATIC", "1");

exe.root_module.addImport("c", c.createModule());
exe.root_module.linkSystemLibrary("foo", .{});
```

Source side:

```zig
const c = @import("c");
_ = c.foo_init();
```

## Static library plus executable

`addLibrary` with `linkage = .static`. The exe picks it up via `linkLibrary`
on its root module; the library's own root module carries its sources.

```zig
const lib_mod = b.createModule(.{
    .root_source_file = b.path("src/lib.zig"),
    .target = target,
    .optimize = optimize,
});
const lib = b.addLibrary(.{
    .name = "mylib",
    .linkage = .static,
    .root_module = lib_mod,
});
b.installArtifact(lib);

exe.root_module.linkLibrary(lib);
```

For a dynamic library use `.linkage = .dynamic`. Consumers of a dynamic
library also need the shared object at runtime.

## Cross-compile for multiple release targets

Useful pattern for shipping binaries: iterate an array of target triples,
install each into its own prefix under `zig-out`.

```zig
const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .x86_64,  .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86_64,  .os_tag = .windows },
};

for (targets) |t| {
    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(t),
        .optimize = .ReleaseFast,
    });
    const release = b.addExecutable(.{
        .name = "myapp",
        .root_module = mod,
    });
    b.installArtifact(release);

    // Optional: isolate outputs per triple.
    const triple = t.zigTriple(b.allocator) catch @panic("OOM");
    const step = b.addInstallArtifact(release, .{
        .dest_dir = .{ .override = .{ .custom = triple } },
    });
    b.getInstallStep().dependOn(&step.step);
}
```

## Build helpers not covered above

Reach into the stdlib when you hit something unfamiliar:

| Need | Where to look |
|------|---------------|
| Emit a generated source file | `Build/Step/WriteFile.zig`, `b.addWriteFiles()` |
| Run an external tool during build | `b.addSystemCommand(&.{ ... })` |
| Pre-compute an asset for `@embedFile` | `b.addRunArtifact` + `addOutputFileArg` |
| Config header (`.h.in` style) | `Build/Step/ConfigHeader.zig`, `b.addConfigHeader` |
| Mutate a checked-in source file | `b.addUpdateSourceFiles()` |

All of the above are on the `Build` namespace or immediately under
`Build/Step/`. If you are not sure of a signature, grep it:

```
STD=$(zig env | awk -F'"' '/\.std_dir/ {print $2}')
grep -rn "^pub fn " "$STD/Build.zig" "$STD/Build/"
```
