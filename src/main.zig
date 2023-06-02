const std = @import("std");
var alloc = @import("alloc.zig").thread_safe_allocator;

pub const Thread = @import("threads").Thread;

export fn entry_point() void {
    run() catch |e| {
        print_string("error");
        print_string(@errorName(e));
    };
}

fn run() !void {
    print_string("Hello from thread 1!");
    const thread = try Thread.spawn(.{}, spawned_entry, .{});
    thread.join();
}

fn spawned_entry() void {
    print_string("Hello from thread 2!");
}

fn print(comptime fmt: []const u8, args: anytype) void {
    var str = std.ArrayList(u8).fromOwnedSlice(alloc, alloc.alloc(u8, 1024) catch @panic("OOM"));
    str.items = str.items[0..0];
    str.capacity = 1024;
    defer str.deinit();

    std.fmt.format(str.writer(), fmt, args) catch std.debug.panic(fmt, args);
    return print_string(str.items);
}

inline fn print_string(s: []const u8) void {
    __print(s.ptr, s.len);
}

inline fn print_number(n: anytype) void {
    const T = @TypeOf(n);
    const info = @typeInfo(T);

    if (info == .Float) {
        return __print_number(@floatCast(f64, n));
    } else if (info == .Int) {
        return __print_number(@intToFloat(f64, n));
    } else {
        @compileError("Provided type isn't a number");
    }
}

extern fn __print(ptr: [*]const u8, len: usize) void;
extern fn __print_number(n: f64) void;
