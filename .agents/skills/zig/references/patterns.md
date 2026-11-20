# Idiomatic Zig 0.16 Patterns

Focused patterns for common situations. Each is short on purpose. Pull up the
stdlib source for edge cases.

## Options struct

Default-valued struct for optional args. Callers set only what they care
about; adding a new option stays source-compatible.

```zig
pub const OpenOptions = struct {
    mode: enum { read, write, read_write } = .read,
    exclusive: bool = false,
};

pub fn open(path: []const u8, options: OpenOptions) !File {
    _ = options.mode;
    _ = options.exclusive;
    _ = path;
    // ...
}

// call site
const f = try open("x.txt", .{});
const g = try open("y.txt", .{ .mode = .read_write });
```

## Errdefer + diagnostics

Rollback partial construction; separately, pass a diagnostics struct so
errors can carry context without widening the error set.

```zig
pub const ParseDiag = struct {
    line: u32 = 0,
    column: u32 = 0,
    message: []const u8 = "",
};

pub fn parse(input: []const u8, diag: ?*ParseDiag) !Ast {
    const arena = ...;
    errdefer arena.deinit();
    _ = input;
    _ = diag;
    return error.Todo;
}
```

Rules of thumb:

- `defer` for cleanup that should always run.
- `errdefer` for cleanup that runs only on the error path (freeing
  half-constructed state).
- Separate diagnostic pointers when you need detail; error sets stay small.

## Arena scoped allocation

Prefer arenas for request/iteration/parse scopes. Free-once rather than
tracking every allocation.

```zig
var arena_state = std.heap.ArenaAllocator.init(gpa);
defer arena_state.deinit();
const arena = arena_state.allocator();

const parts = try parseExpensiveThing(arena, input);
_ = try render(arena, parts);
// everything freed on arena_state.deinit()
```

In 0.16 the `ArenaAllocator` is thread-safe and lock-free by default, so a
single arena can back parallel tasks.

## Writer with a custom format method

```zig
const Point = struct {
    x: f32,
    y: f32,

    pub fn format(self: Point, w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.print("Point({d}, {d})", .{ self.x, self.y });
    }
};

// usage
try out.print("p = {f}\n", .{Point{ .x = 1, .y = 2 }});
```

`{f}` is specifically the "call the type's format method" specifier. Using
it on a primitive that has no `format` method is a compile error.

## Concurrent tasks with Io.Group

Each task function must return `std.Io.Cancelable!void`. `Group.async` itself
returns `void` (not an error) - failures are surfaced from `await`.

```zig
fn fetchOne(io: std.Io, url: []const u8) std.Io.Cancelable!void {
    _ = io;
    _ = url;
    // ... do the fetch
}

var group: std.Io.Group = .init;
errdefer group.cancel(io); // release tasks on the error path

group.async(io, fetchOne, .{ io, "a" });
group.async(io, fetchOne, .{ io, "b" });
group.async(io, fetchOne, .{ io, "c" });

try group.await(io); // blocks until all finish; returns error.Canceled on cancel
```

Group cleanup happens through `await` or `cancel`; there is no separate
`deinit`. For lower-level batching of heterogenous operations see
`std.Io.Batch`; for waiting on whichever future completes first see
`std.Io.Select`; for a single-task handle use `std.Io.Future(T)`. Grep
`$(zig env | awk -F'"' '/\.std_dir/ {print $2}')/Io.zig` for the exact
signatures - the API is young and may sharpen between point releases.

## Comptime duck-typed generics

Prefer `comptime T: type` with structural use over tagged type parameters.
The compiler enforces the "shape" by how the value is used.

```zig
pub fn sum(comptime T: type, xs: []const T) T {
    var acc: T = 0;
    for (xs) |x| acc += x;
    return acc;
}
```

When you need an opaque interface (not generic), use the vtable pattern
`std.mem.Allocator` demonstrates: a pointer to user data plus a vtable of
function pointers. Grep `mem/Allocator.zig` under the stdlib (resolve with
`zig env`, field `.std_dir`) to see the shape.

## Labelled switch for state machines

```zig
const State = enum { idle, running, done };
var result: u32 = 0;

state: switch (State.idle) {
    .idle => continue :state .running,
    .running => {
        result += 1;
        if (result < 10) continue :state .running;
        continue :state .done;
    },
    .done => break :state,
}
```

## Decl literals

`.identifier` resolves against the target type's decls. Works with `try`.

```zig
const Color = struct {
    r: u8, g: u8, b: u8,
    pub const black: Color = .{ .r = 0, .g = 0, .b = 0 };
    pub fn rgb(r: u8, g: u8, b: u8) Color { return .{ .r = r, .g = g, .b = b }; }
};

const a: Color = .black;
const b: Color = .rgb(10, 20, 30);
```

## Threading io through helpers

A helper that touches I/O must accept `io` explicitly:

```zig
fn writeGreeting(io: std.Io, w: *std.Io.Writer) !void {
    try w.writeAll("hello\n");
    _ = io; // some helpers need it, some don't - pass it if you might
}
```

If you find yourself wishing for a global `io`, you are doing it wrong. The
point of 0.16's interface is that the caller picks the implementation
(`Threaded`, `Evented`, `Uring`, ...); a global would break that.
