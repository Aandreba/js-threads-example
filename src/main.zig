const std = @import("std");
var alloc = std.heap.page_allocator;

pub const Thread = @import("threads").Thread;

export fn entry_point() void {
    print_string("Hello from thread 1!");

    const thread = Thread.spawn(.{}, spawned_entry, .{}) catch |e| return print("error: {}", .{e});
    thread.join();
}

fn spawned_entry() void {
    print_string("Hello form thread 2");
}

fn print(comptime fmt: []const u8, args: anytype) void {
    var str = std.ArrayList(u8).init(alloc);
    defer str.deinit();

    std.fmt.format(str.writer(), fmt, args) catch return print_string("formating error");
    return print_string(str.items);
}

inline fn print_string(s: []const u8) void {
    __print(s.ptr, s.len);
}

extern fn __print(ptr: [*]const u8, len: usize) void;
