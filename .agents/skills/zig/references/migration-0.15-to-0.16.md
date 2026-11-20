# Migration: Zig 0.15 to 0.16

Side-by-side recipes for porting an existing 0.15 codebase. The 0.16 release
threads an explicit `std.Io` interface through filesystem, network, process,
and synchronisation APIs. Most migration work is plumbing `io` through call
chains.

## Main function

```zig
// 0.15
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    // ...
}

// 0.16 - Juicy Main
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    const arena = init.arena.allocator();
    // ...
}
```

If you need the old minimal signature (args + environ only), use:

```zig
pub fn main(init: std.process.Init.Minimal) !void { ... }
```

## Standard I/O

```zig
// 0.15
const stdout_file = std.io.getStdOut();
var bw = std.io.bufferedWriter(stdout_file.writer());
const stdout = bw.writer();
try stdout.print("hello\n", .{});
try bw.flush();

// 0.16
var buf: [4096]u8 = undefined;
var w = std.Io.File.stdout().writer(io, &buf);
const stdout = &w.interface;
try stdout.print("hello\n", .{});
try stdout.flush();
```

`BufferedWriter` is gone; the buffer is part of the writer now.

## Files

```zig
// 0.15
const file = try std.fs.cwd().openFile("foo.txt", .{});
defer file.close();
const len = try file.getEndPos();
const data = try file.readToEndAlloc(allocator, max);

// 0.16
const file = try std.Io.Dir.cwd().openFile(io, "foo.txt", .{});
defer file.close(io);
const len: usize = @intCast(try file.length(io));
const data = try gpa.alloc(u8, len);
defer gpa.free(data);
var rbuf: [4096]u8 = undefined;
var fr = file.reader(io, &rbuf);
_ = try fr.interface.readSliceAll(data);
```

## Directories

```zig
// 0.15
try std.fs.cwd().makeDir("out");
try std.fs.cwd().makePath("a/b/c");

// 0.16
try std.Io.Dir.cwd().createDir(io, "out", .default_dir);
try std.Io.Dir.cwd().createDirPath(io, "a/b/c");
```

Directory iteration signatures also take `io` now. Grep `Io/Dir.zig` for the
exact current shape.

## Processes

```zig
// 0.15
var child = std.process.Child.init(&.{ "ls", "-la" }, allocator);
child.stdin_behavior = .Ignore;
try child.spawn();
const term = try child.wait();

// 0.16
var child = try std.process.spawn(io, .{
    .argv = &.{ "ls", "-la" },
    .stdin = .ignore,
});
const term = try child.wait(io);
```

Most cancellable operations can now return `error.Canceled`; account for it
in your error set or propagate.

## Synchronisation

```zig
// 0.15
var mutex: std.Thread.Mutex = .{};
mutex.lock();
defer mutex.unlock();

// 0.16
var mutex: std.Io.Mutex = .{};
mutex.lock(io);
defer mutex.unlock();
```

Similarly:

- `std.Thread.Condition` -> `std.Io.Condition`
- `std.Thread.ResetEvent` -> `std.Io.Event`
- `std.Thread.Semaphore` -> `std.Io.Semaphore`
- `std.Thread.RwLock` -> `std.Io.RwLock`
- `std.Thread.WaitGroup` -> `std.Io.Group`

Removed with no drop-in:

- `std.Thread.Pool` - build concurrency on top of `Io.Group` / `Io.Batch` /
  `Io.Future`.
- `std.once` - use `Io.Mutex` + a flag, or a one-shot `Io.Event`.
- `std.heap.ThreadSafeAllocator` - `ArenaAllocator` is now thread-safe; other
  allocators typically have their own concurrency story.

## @Type builtins

```zig
// 0.15
const U10 = @Type(.{ .int = .{ .signedness = .unsigned, .bits = 10 } });
const PairType = @Type(.{ .@"struct" = .{
    .layout = .auto,
    .fields = &.{ ... },
    .decls = &.{},
    .is_tuple = false,
} });

// 0.16
const U10 = @Int(.unsigned, 10);
const PairType = @Struct(.auto, null, &.{ "x", "y" }, &.{ u32, u32 }, .{});
```

Grep `builtin.zig` under the stdlib (resolve with `zig env`, field `.std_dir`)
for `pub const Type` to see the reflection structure `@typeInfo` returns; it
is unchanged.

## Float conversions

```zig
// 0.15
const x: u32 = @intFromFloat(v);          // any non-integer float -> UB unless truncated first
const y: f32 = @floatFromInt(small_int);  // always needed

// 0.16
const x: u32 = @trunc(v);                 // @trunc/@floor/@ceil/@round now do int conversion
const y: f32 = small_int;                 // implicit when it fits (u24 -> f32, u53 -> f64, ...)
```

## @cImport

```zig
// 0.15 (still works in 0.16 but deprecated)
const c = @cImport(@cInclude("stdio.h"));

// 0.16 (preferred)
// In build.zig:
const c_mod = b.addTranslateC(.{
    .root_source_file = b.path("src/c_imports.h"),
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("c", c_mod.createModule());

// In source:
const c = @import("c");
```

## Containers

Already covered in the 0.14/0.15 migration, but worth repeating:

```zig
// 0.15 already broken but some pre-0.15 code persists
var list: std.ArrayList(u32) = .{};

// Correct 0.15/0.16
var list: std.ArrayList(u32) = .empty;
```

`std.ArrayListUnmanaged` is the old name of `std.ArrayList`;
`std.heap.GeneralPurposeAllocator` is the old name of `std.heap.DebugAllocator`.

## Format method

```zig
// 0.15 (already wrong - old 4-arg form predates that)
pub fn format(self: S, w: anytype) !void { ... }

// 0.16
pub fn format(self: S, w: *std.Io.Writer) std.Io.Writer.Error!void {
    try w.print("S({d})", .{self.x});
}
```

Use `std.fmt.Alt` (formerly `std.fmt.Formatter`) to wrap a non-method
formatter function.

## Build system

No structural change from 0.15:

- `root_source_file` as a direct field on `addExecutable` is still gone. Use
  `root_module = b.createModule(.{...})`.
- `exe.addModule` still gone. Use `exe.root_module.addImport`.
- Compile-level C helpers still deprecated. Call them on `exe.root_module`.

What changed in 0.16: `b.addTranslateC` is now the recommended replacement
for `@cImport`, and `build.zig.zon` supports overriding dependencies locally.

## Errors

| Old | New |
|-----|-----|
| `error.RenameAcrossMountPoints` | `error.CrossDevice` |
| `error.NotSameFileSystem` | `error.CrossDevice` |
| `error.SharingViolation` | `error.FileBusy` |
| `error.EnvironmentVariableNotFound` | `error.EnvironmentVariableMissing` |

Many cancellable APIs now return `error.Canceled`; audit error sets when
migrating.
