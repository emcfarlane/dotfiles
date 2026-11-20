---
name: zig
description: Up-to-date Zig 0.16.0 patterns and lookup protocol. Use whenever writing, reviewing, or debugging Zig code, editing build.zig or build.zig.zon, or working in any repo containing .zig files. Critical because training data predates 0.16's breaking changes: the std.Io interface threaded through fs/net/process/sync, removal of @Type in favor of @Int/@Tuple/@Pointer/@Struct/@Union/@Enum/@Fn/@EnumLiteral, the Juicy Main signature main(init: std.process.Init), renamed sync primitives under std.Io, and deprecated @cImport/@intFromFloat/async/await/usingnamespace. Consult this skill before writing any Zig to avoid confident-but-wrong 0.11-0.15 patterns.
---

# Zig 0.16.0

Zig 0.16.0 shipped with sweeping breaking changes. Training data is mostly
0.11-0.13 era and will confidently produce patterns that do not compile.
This skill has two jobs: list the specific traps, and teach you to verify
against the local stdlib rather than guess.

## Lookup protocol

The local stdlib is the authoritative reference, not this file.

Discover the install paths with `zig env` (ZON output). Never hardcode:

```
zig env | awk -F'"' '/\.std_dir/  {print $2}'   # e.g. /path/to/zig/lib/std
zig env | awk -F'"' '/\.lib_dir/  {print $2}'   # parent of std_dir
zig env | awk -F'"' '/\.version/  {print $2}'   # sanity-check version
```

HTML docs: run `zig std` (serves on a local port).

When you are unsure of an API, do not guess. Do this instead:

1. Resolve the stdlib path from `zig env` and grep it. Public members start
   with `pub fn` or `pub const`. Example:

   ```
   STD=$(zig env | awk -F'"' '/\.std_dir/ {print $2}')
   grep -n "^pub fn\|^pub const" "$STD/Io/File.zig"
   ```

2. Read the function signature as ground truth. Docstrings above the signature
   often explain which related function to use.
3. Verify snippets before finishing. Use the most targeted tool:
   - `zig ast-check <file>` for parse-only
   - `zig build-obj <file>` for type-check without a main
   - `zig build-exe <file>` for full compile
4. If you cannot confirm something in the stdlib, say so. Do not invent an API.

This is the single most important habit for 0.16 work. Training data lies;
the stdlib does not.

## Hello, 0.16

Every detail below is a 0.15 to 0.16 change. Start here when writing anything.

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [4096]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const out = &w.interface;
    try out.writeAll("hello, zig 0.16\n");
    try out.flush();
}
```

- `main` takes `std.process.Init`. It exposes `io`, `gpa`, `arena`,
  `environ_map`, `preopens`. Use `std.process.Init.Minimal` if you only need
  args/environ.
- `std.Io.File.stdout()` replaces `std.io.getStdOut()`.
- `.writer(io, &buf)` requires both `io` and a buffer. The `io` param is not
  optional and is the most common thing training data gets wrong.
- Writers are non-generic. Grab `&w.interface` for the concrete
  `*std.Io.Writer`.
- `.flush()` is mandatory. Buffered output without a final flush is silently
  truncated on program exit.

## The Io interface: the single biggest change

`std.Io` is an explicit interface passed to every fs, net, process, and sync
call. The `Init` struct hands you one; thread it through.

```zig
// File I/O
const file = try std.Io.Dir.cwd().openFile(io, "foo.txt", .{});
defer file.close(io);

// Read the whole file
const len: usize = @intCast(try file.length(io));
const data = try gpa.alloc(u8, len);
defer gpa.free(data);
var rbuf: [4096]u8 = undefined;
var fr = file.reader(io, &rbuf);
_ = try fr.interface.readSliceAll(data);

// Directories
try std.Io.Dir.cwd().createDir(io, "newdir", .default_dir);
var dir = try std.Io.Dir.cwd().openDir(io, "somedir", .{});
defer dir.close(io);

// Processes
var child = try std.process.spawn(io, .{
    .argv = &.{ "echo", "hi" },
    .stdin = .ignore,
});
_ = try child.wait(io);
```

Renames worth memorising:

- `std.fs.cwd()` -> `std.Io.Dir.cwd()`
- `fs.Dir.makeDir` -> `Io.Dir.createDir`
- `fs.Dir.makePath` -> `Io.Dir.createDirPath`
- `file.getEndPos` -> `file.length`
- `file.setEndPos` -> `file.setLength`
- `file.read` -> `file.readStreaming` (raw syscall) or use the `Reader`
  interface for buffered reads
- `file.write` -> `file.writeStreaming` (raw) or use the `Writer` interface

## Sync primitives moved to std.Io

| Old | New |
|-----|-----|
| `std.Thread.Mutex` | `std.Io.Mutex` |
| `std.Thread.Condition` | `std.Io.Condition` |
| `std.Thread.ResetEvent` | `std.Io.Event` |
| `std.Thread.Semaphore` | `std.Io.Semaphore` |
| `std.Thread.RwLock` | `std.Io.RwLock` |
| `std.Thread.WaitGroup` | `std.Io.Group` |

Removed entirely: `Thread.Pool`, `std.once`, `Thread.Mutex.Recursive`,
`std.heap.ThreadSafeAllocator` (ArenaAllocator is now thread-safe and
lock-free by default).

New concurrency types: `std.Io.Future(T)`, `std.Io.Group`, `std.Io.Batch`,
`std.Io.Select`, and cancellation via `error.Canceled` threaded through the
interface.

## Builtins: @Type split apart

`@Type` was removed. Use the specific builtin:

```zig
// Old form                                                -> New form
@Type(.{ .int = .{ .signedness = .unsigned, .bits = 10 } }) // -> @Int(.unsigned, 10)
@Type(.{ .pointer = ... })                                  // -> @Pointer(size, attrs, Child, sentinel)
@Type(.{ .@"struct" = ... })                                // -> @Struct(layout, backing, names, types, attrs)
@Type(.{ .@"union" = ... })                                 // -> @Union(layout, tag, names, types, attrs)
@Type(.{ .@"enum" = ... })                                  // -> @Enum(tag_int, mode, names, values)
@Type(.{ .@"fn" = ... })                                    // -> @Fn(params, attrs, Ret, fn_attrs)
@Type(.{ .enum_literal = {} })                              // -> @EnumLiteral()
```

`@typeInfo` still returns `std.builtin.Type` and is unchanged for
introspection. The `@Type` removal only affects type *construction*.

Other builtin changes:

- `@intFromFloat` deprecated. Use `@trunc`, `@floor`, `@ceil`, `@round` -
  they now perform float-to-int conversion when the result type is integer.
- `@cImport` deprecated. Use `b.addTranslateC` in build.zig.
- Small ints coerce to floats implicitly when they fit in the mantissa; drop
  `@floatFromInt` for u24 -> f32, u53 -> f64, etc.
- `@branchHint(.cold)` replaces the old `@setCold(true)` (carried from 0.14).
- `@export` takes a pointer: `@export(&foo, .{ .name = "bar" })`.

## Removals still in play from 0.15

- `usingnamespace`: removed. Explicit re-export only.
- `async` / `await` keywords: removed from the language. Use `std.Io.Future`
  and friends.
- `std.BoundedArray`: removed. Use `std.ArrayList(T).initBuffer(&buffer)`.
- `std.SegmentedList`: removed.
- Vector runtime indexing: forbidden. Coerce to array first.
- Returning a pointer to a local var: compile error.

## Containers

Never use `.{}` for containers. Use `.empty` for empty collections, `.init`
for stateful types.

```zig
var list: std.ArrayList(u32) = .empty;
var map: std.AutoHashMapUnmanaged(u32, u32) = .empty;

var gpa: std.heap.DebugAllocator(.{}) = .init;
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
```

- `std.ArrayListUnmanaged` was renamed to `std.ArrayList` (old name deprecated).
- `std.heap.GeneralPurposeAllocator` is now `std.heap.DebugAllocator` (alias
  still works but prefer the new name).

## Format strings

Basic specifiers unchanged: `{d}` integers, `{s}` strings, `{x}` hex, `{}`
default repr.

`{f}` specifically calls a type's `format` method. Using `{f}` on a primitive
type that has no `format` method produces a compile error. The method
signature changed:

```zig
// Old (4-arg) signature - gone
pub fn format(self: @This(), comptime fmt: []const u8, opts: std.fmt.FormatOptions, writer: anytype) !void

// New signature
pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void {
    try w.print("MyType({d})", .{self.x});
}
```

`std.fmt.Formatter` was renamed to `std.fmt.Alt`.

## Build system

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Local module import
    const helper = b.createModule(.{
        .root_source_file = b.path("src/helper.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("helper", helper);

    // Dependency (from build.zig.zon)
    // const lib = b.dependency("lib", .{ .target = target, .optimize = optimize });
    // exe.root_module.addImport("lib", lib.module("lib"));

    // C headers: addTranslateC replaces @cImport
    // const c = b.addTranslateC(.{
    //     .root_source_file = b.path("src/c.h"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe.root_module.addImport("c", c.createModule());

    b.installArtifact(exe);
}
```

`root_source_file` as a field on `addExecutable` is gone - use `root_module`
with `b.createModule`. Compile-level helpers (`exe.linkSystemLibrary`,
`exe.addCSourceFiles`, `exe.addIncludePath`, `exe.linkLibC`) are deprecated;
call them on `exe.root_module` instead.

## Error renames

| Old | New |
|-----|-----|
| `error.RenameAcrossMountPoints`, `error.NotSameFileSystem` | `error.CrossDevice` |
| `error.SharingViolation` | `error.FileBusy` |
| `error.EnvironmentVariableNotFound` | `error.EnvironmentVariableMissing` |

## Quick-fix table

| Compiler error | Fix |
|----------------|-----|
| `invalid builtin function: '@Type'` | Use `@Int` / `@Tuple` / `@Pointer` / `@Struct` / `@Union` / `@Enum` / `@Fn` / `@EnumLiteral` |
| `member function expected 2 argument(s)` on `.writer(&buf)` | Add `io`: `.writer(io, &buf)` |
| `member function expected 2 argument(s)` on `file.close()` | `file.close(io)` |
| `no field named 'root_source_file'` | Use `root_module = b.createModule(.{ ... })` |
| `no field or member function named 'format' in 'X'` with `{f}` | Use `{d}` / `{s}` / `{}`; `{f}` only calls a type's own format method |
| `invalid builtin function: '@cImport'` | Use `b.addTranslateC` in build.zig |
| `undefined identifier 'BoundedArray'` | `std.ArrayList(T).initBuffer(&buf)` |
| `error: use of deprecated identifier 'once'` | Removed - use `Io.Mutex` + a flag, or a one-shot `Io.Event` |
| Missing `io` argument on fs/net/process call | Thread `init.io` through from main |
| `sanitize_c = true` rejected | Type changed to `?std.zig.SanitizeC`; use `.full`, `.trap`, or `.off` |

## References

Read these when the situation calls for them. They are opt-in, not
auto-loaded.

- **[Migration 0.15 to 0.16](references/migration-0.15-to-0.16.md)** - side-
  by-side old/new for each breaking change. Load when porting a 0.15 codebase.
- **[Idiomatic patterns](references/patterns.md)** - errdefer + diagnostics,
  options-struct idiom, arena-scoped allocation, Io.Group concurrency, custom
  format. Load when writing non-trivial new code.
- **[Code review checklist](references/code-review.md)** - confidence-tiered:
  always flag / flag with context / suggest. Load when reviewing Zig.
- **[Build system recipes](references/build-system.md)** - verified build.zig
  snippets: test/run steps, user options (`-D`), deps from `build.zig.zon`,
  `addTranslateC`, libraries, multi-target release. Load when editing
  `build.zig`. Deep tutorial: https://ziglang.org/learn/build-system/.

When these references do not answer your question, read the stdlib source
directly. It is authoritative.
