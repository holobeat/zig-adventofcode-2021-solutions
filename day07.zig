const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const utils = @import("utils.zig");

fn printArray(items: []u32) void {
    for (items) |n| print("{d} ", .{n});
    print("\n", .{});
}

fn part2Fuel(steps: u32) u32 {
    var i: u32 = 1;
    var f: u32 = 0;
    while (i <= steps) : (i += 1) {
        f += i;
    }
    return f;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var buff = try utils.readFile(allocator, "day07_input.txt");
    defer allocator.free(buff);

    var lines = std.mem.split(u8, buff, ",");

    var data = ArrayList(u32).init(allocator);
    defer data.deinit();

    // PART 1
    while (lines.next()) |c| {
        if (c.len == 0) continue;
        var n = try std.fmt.parseInt(u32, std.mem.trim(u8, c, "\n"), 10);
        try data.append(n);
    }

    std.sort.sort(u32, data.items, {}, comptime std.sort.asc(u32));

    var max_n = data.items[data.items.len - 1];

    // PART 1
    {
        var distance: u32 = 0xFFFFFFFF;
        var prev_n: u32 = undefined;
        var best_n: u32 = undefined;
        var n: u32 = 0;

        while (n <= max_n) : (n += 1) {
            if (prev_n != n) {
                var d: u32 = 0;
                for (data.items) |k| {
                    if (k != n) {
                        d += if (k < n) n - k else k - n;
                    }
                }
                if (d < distance) {
                    distance = d;
                    best_n = n;
                }
            }
            prev_n = n;
        }

        print("Solution part 1: {d}\n", .{distance});
    }

    // PART 2
    {
        var distance: u32 = 0xFFFFFFFF;
        var prev_n: u32 = undefined;
        var best_n: u32 = undefined;
        var n: u32 = 0;

        while (n <= max_n) : (n += 1) {
            if (prev_n != n) {
                var d: u32 = 0;
                for (data.items) |k| {
                    if (k != n) {
                        d += part2Fuel(if (k < n) n - k else k - n);
                    }
                }
                if (d < distance) {
                    distance = d;
                    best_n = n;
                }
            }
            prev_n = n;
        }

        print("Solution part 2: {d}\n", .{distance});
    }
}
