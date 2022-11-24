const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const utils = @import("utils.zig");

fn printFish(items: []u8) void {
    for (items) |n| print("{d} ", .{n});
    print("\n", .{});
}

fn sumFish(items: []usize) usize {
    var sum: usize = 0;
    for (items) |n| sum += n;
    return sum;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var buff = try utils.readFile(allocator, "day06_input.txt");
    defer allocator.free(buff);

    var lines = std.mem.split(u8, buff, ",");

    var data = ArrayList(u8).init(allocator);
    defer data.deinit();

    // PART 1 - brute force
    while (lines.next()) |c| {
        if (c.len == 0) continue;
        var n = try std.fmt.parseInt(u8, std.mem.trim(u8, c, "\n"), 10);
        try data.append(n);
    }

    var i: usize = 0;
    while (i < 80) : (i += 1) {
        var spawn: isize = 0;
        for (data.items) |*n| {
            if (n.* == 0) {
                n.* = 6;
                spawn += 1;
            } else {
                n.* -= 1;
            }
        }
        while (spawn > 0) : (spawn -= 1) try data.append(8);
    }
    print("Solution part 1: {d}\n", .{data.items.len});

    data.clearAndFree();
    lines.reset();
    i = 0;

    // PART 2 - using cyclic array
    // Credit where credit is due: Love Sharma at:
    // https://medium.com/interviewnoodle/lantern-fish-day-6-advent-of-code-2021-python-solution-4444387a8380
    // Solving this using the "brute force" way would take forever to finish.

    while (lines.next()) |c| {
        if (c.len == 0) continue;
        var n = try std.fmt.parseInt(u8, std.mem.trim(u8, c, "\n"), 10);
        try data.append(n);
    }

    var buckets = [1]usize{0} ** 9;
    for (data.items) |n| buckets[n] += 1; // fill the buckets with initial fish

    var today: usize = undefined;
    
    while (i < 256) : (i += 1) {
        today = i % buckets.len;
        buckets[(today + 7) % buckets.len] += buckets[today];
    }
    
    print("Solution part 2: {d}\n", .{sumFish(buckets[0..])});
}
