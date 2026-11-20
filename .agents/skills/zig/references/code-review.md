# Zig 0.16 Code Review Checklist

Confidence-tiered. Use when reviewing Zig code.

## Always flag (these are definitely wrong in 0.16)

**Removed features and builtins**

- `usingnamespace` - removed. The file must explicitly re-export.
- `async` / `await` keywords - removed. Code using them will not compile.
  `std.Io.Future`, `Group`, `Batch`, `Select` are the replacement.
- `@Type(...)` for type construction - removed. Must use `@Int`, `@Tuple`,
  `@Pointer`, `@Struct`, `@Union`, `@Enum`, `@Fn`, or `@EnumLiteral`.
- `@cImport(...)` - deprecated; should be `b.addTranslateC` in build.zig.
- `@intFromFloat(...)` - deprecated; use `@trunc`, `@floor`, `@ceil`, or
  `@round` on an integer result type.
- `@setCold(true)` - use `@branchHint(.cold)`.
- `@export(foo, ...)` without `&` - must be `@export(&foo, ...)`.
- `@fence(...)` - removed. Use atomic orderings or RMW operations.
- `std.BoundedArray` - removed. `std.ArrayList(T).initBuffer(&buf)`.
- `std.SegmentedList` - removed.
- `std.Thread.Pool`, `std.once`, `std.Thread.Mutex.Recursive`,
  `std.heap.ThreadSafeAllocator` - removed.

**Missing io parameter**

If a function name looks like it touches the filesystem, network, a process,
or a sync primitive and there is no `io` argument, it is probably wrong.
Threaded pattern: `file.close(io)`, `file.reader(io, &buf)`,
`Dir.cwd().openFile(io, path, .{})`, `std.process.spawn(io, ...)`,
`mutex.lock(io)`.

**Build system**

- `root_source_file` field directly on `addExecutable`/`addLibrary`/`addTest`
  - removed. Must be `root_module = b.createModule(.{...})`.
- `exe.addModule("name", mod)` - removed. Must be
  `exe.root_module.addImport("name", mod)`.

**Missing flush**

Buffered writes are silently truncated on program exit if `flush` is never
called. Every `Io.Writer` fed by a buffer needs `try out.flush();` before the
last control flow out of the function.

**Containers**

- `var list: std.ArrayList(T) = .{};` - use `.empty`.
- `var gpa: std.heap.DebugAllocator(.{}) = .{};` - use `.init`.

## Flag with context (likely wrong but sometimes defensible)

**Format method signature**

The old 4-arg `format(self, comptime fmt, opts, writer)` and the
3-arg intermediate `format(self, w: anytype)` forms are both wrong. Current:

```zig
pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void
```

Old code may carry stale signatures that only break when `{f}` actually calls
them.

**`{f}` on primitives**

`{f}` is the "call the type's format method" specifier. Using it on an
integer or float is a compile error. The author probably wanted `{d}`.

**Allocator leaks**

- `DebugAllocator` without `defer _ = gpa.deinit();` - leak detector is off.
- Paired `alloc`/`free` - prefer `defer gpa.free(x);` right after the alloc.
  If allocations are scope-shaped, a single `ArenaAllocator.deinit()` is
  simpler and safer.
- `errdefer` for partially constructed state; `defer` for always-cleanup.

**Unhandled cancellation**

Many `Io`-parameterised APIs return `error.Canceled`. If the function lives
under `std.Io.Evented` or within a `Group`, an unhandled `Canceled` may mask
propagation bugs.

**Vector runtime indexing**

`vec[i]` at runtime is forbidden in 0.16. If you see it, the code needs to
coerce to an array first.

**Returning a pointer to a local**

```zig
fn bad() *i32 {
    var x: i32 = 0;
    return &x; // compile error in 0.16
}
```

Heap-allocate or take a pointer parameter the caller owns.

**Packed struct/union with pointer field**

Pointers are not allowed in packed layouts. Must be `usize` + manual
`@ptrFromInt` / `@intFromPtr`.

## Suggest (style and ergonomics)

- Naming: types `TitleCase`, functions `camelCase`, variables and fields
  `snake_case`. The compiler does not enforce but `zig fmt` and the broader
  ecosystem do.
- Prefer `for` over `while` when the iteration count is known.
- Prefer `inline for` only for comptime-known counts where the body benefits
  from specialisation, not as a generic "make it fast" knob.
- Prefer `.empty` / `.init` / decl literals over re-typing the type name.
- Prefer options-struct parameters with defaults over long argument lists.
- Use arena allocators for parse/request scopes. Smaller diff on error paths.
- Keep error sets narrow. Reach for a diagnostics struct when callers need
  context beyond the error tag.

## Verification hooks

When in doubt, run:

```
zig ast-check path.zig          # parse only
zig build-obj path.zig          # type-check, no main
zig build-exe path.zig          # full compile
zig build                       # project-level
```

If the author says an API exists but you cannot find it by grep, the author
is probably wrong. Insist on a `pub fn` / `pub const` citation.
