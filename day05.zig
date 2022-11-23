// --- Day 5: Hydrothermal Venture ---
// You come across a field of hydrothermal vents on the ocean floor! These
// vents constantly produce large, opaque clouds, so it would be best
// to avoid them if possible.
//
// They tend to form in lines; the submarine helpfully produces a list of
// nearby lines of vents (your puzzle input) for you to review. For example:
//
// 0,9 -> 5,9
// 8,0 -> 0,8
// 9,4 -> 3,4
// 2,2 -> 2,1
// 7,0 -> 7,4
// 6,4 -> 2,0
// 0,9 -> 2,9
// 3,4 -> 1,4
// 0,0 -> 8,8
// 5,5 -> 8,2
//
// Each line of vents is given as a line segment in the format x1,y1 -> x2,y2
// where x1,y1 are the coordinates of one end the line segment and x2,y2 are
// the coordinates of the other end. These line segments include the points at
// both ends. In other words:
//
// An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
// An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
//
// For now, only consider horizontal and vertical lines: lines where either
// x1 = x2 or y1 = y2.
//
// So, the horizontal and vertical lines from the above list would produce
// the following diagram:
//
// .......1..
// ..1....1..
// ..1....1..
// .......1..
// .112111211
// ..........
// ..........
// ..........
// ..........
// 222111....
//
// In this diagram, the top left corner is 0,0 and the bottom right corner
// is 9,9. Each position is shown as the number of lines which cover that point
// or . if no line covers that point. The top-left pair of 1s, for example,
// comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping
// lines 0,9 -> 5,9 and 0,9 -> 2,9.
//
// To avoid the most dangerous areas, you need to determine the number of
// points where at least two lines overlap. In the above example, this is
// anywhere in the diagram with a 2 or larger - a total of 5 points.

// Consider only horizontal and vertical lines. At how many points do at least
// two lines overlap?
//
// --- Part Two ---
// Unfortunately, considering only horizontal and vertical lines doesn't give
// you the full picture; you need to also consider diagonal lines.
//
// Because of the limits of the hydrothermal vent mapping system, the lines
// in your list will only ever be horizontal, vertical, or a diagonal line
// at exactly 45 degrees. In other words:
//
// An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
// An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
//
// Considering all lines from the above example would now produce the following
// diagram:
//
// 1.1....11.
// .111...2..
// ..2.1.111.
// ...1.2.2..
// .112313211
// ...1.2....
// ..1...1...
// .1.....1..
// 1.......1.
// 222111....
//
// You still need to determine the number of points where at least two lines
// overlap. In the above example, this is still anywhere in the diagram with
// a 2 or larger - now a total of 12 points.
//
// Consider all of the lines. At how many points do at least two lines overlap?

const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const trim = std.mem.trim;
const absCast = std.math.absCast;
const cast = std.math.cast;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const utils = @import("utils.zig");

fn nextInt(comptime T: type, iter: *std.mem.SplitIterator(u8)) usize {
    return parseInt(T, trim(u8, iter.next().?, " "), 10) catch unreachable;
}

fn isLine(x1: usize, y1: usize, x2: usize, y2: usize) bool {
    return x1 == x2 or y1 == y2;
}

fn normalizeVector(x1: usize, y1: usize, x2: usize, y2: usize) [4]usize {
    var v = [_]usize{ x1, y1, x2, y2 };
    if (x1 > x2) v = [_]usize{ x2, y1, x1, y2 };
    if (y1 > y2) v = [_]usize{ v[0], y2, v[2], y1 };
    return v;
}

fn plot(x: usize, y: usize, field: *[]usize, width: usize) void {
    var i = width * y + x;
    field.*[i] += 1;
    return;
}

fn printField(field: []usize, width: usize) void {
    print("field len = {d}\n", .{field.len});
    for (field) |f, i| {
        print("{d:3}{s}", .{ f, if (i % width == width - 1) "\n" else "" });
    }
}

fn intersectCount(field: []usize, at_least: usize) usize {
    var c: usize = 0;
    for (field) |f| {
        if (f >= at_least) c += 1;
    }
    return c;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var buff = try utils.readFile(allocator, "day05_input.txt");
    defer allocator.free(buff);

    var lines = std.mem.split(u8, buff, "\n");

    var data = ArrayList([4]usize).init(allocator);
    defer data.deinit();

    var max_x: usize = 0;
    var max_y: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var str_pairs = std.mem.split(u8, line, "->");

        var str_first = str_pairs.next() orelse unreachable;
        var str_second = str_pairs.next() orelse unreachable;

        var str_first_iter = std.mem.split(u8, str_first, ",");
        var str_second_iter = std.mem.split(u8, str_second, ",");

        var x1 = nextInt(usize, &str_first_iter);
        var y1 = nextInt(usize, &str_first_iter);
        var x2 = nextInt(usize, &str_second_iter);
        var y2 = nextInt(usize, &str_second_iter);

        if (@max(x1, x2) > max_x) max_x = @max(x1, x2);
        if (@max(y1, y2) > max_y) max_y = @max(y1, y2);
        try data.append(
            if (isLine(x1, y1, x2, y2)) normalizeVector(x1, y1, x2, y2) else [_]usize{ x1, y1, x2, y2 },
        );
    }

    var width: usize = max_x + 1;

    print("\n", .{});

    var field = try allocator.alloc(usize, (max_x + 1) * (max_y + 1));
    defer allocator.free(field);

    for (field[0..]) |*f| f.* = 0; // reset field

    // part 1
    {
        for (data.items) |n| {
            if (isLine(n[0], n[1], n[2], n[3])) {
                if (n[0] == n[2]) {
                    var i: usize = 0;
                    while (i <= n[3] - n[1]) : (i += 1) {
                        plot(n[0], n[1] + i, &field, width);
                    }
                } else if (n[1] == n[3]) {
                    var i: usize = 0;
                    while (i <= n[2] - n[0]) : (i += 1) {
                        plot(n[0] + i, n[3], &field, width);
                    }
                }
            }
        }
        print("Solution part 1: max = {d}\n", .{intersectCount(field, 2)});
    }

    for (field[0..]) |*f| f.* = 0; // reset field

    // part 2
    {
        for (data.items) |n| {
            if (isLine(n[0], n[1], n[2], n[3])) {
                if (n[0] == n[2]) {
                    var i: usize = 0;
                    while (i <= n[3] - n[1]) : (i += 1) {
                        plot(n[0], n[1] + i, &field, width);
                    }
                } else if (n[1] == n[3]) {
                    var i: usize = 0;
                    while (i <= n[2] - n[0]) : (i += 1) {
                        plot(n[0] + i, n[3], &field, width);
                    }
                }
            } else {
                // assume diagonal line
                var dx: isize = if (n[0] > n[2]) -1 else 1;
                var dy: isize = if (n[1] > n[3]) -1 else 1;
                var i: isize = 0;
                var steps = if (n[0] > n[2]) n[0] - n[2] else n[2] - n[0];
                while (i <= steps) : (i += 1) {
                    // leap of faith with "orelse 0"... there should be better way
                    var x = absCast((cast(isize, n[0]) orelse 0) + (i * dx));
                    var y = absCast((cast(isize, n[1]) orelse 0) + (i * dy));
                    plot(x, y, &field, width);
                }
            }
        }
        print("Solution part 2: max = {d}", .{intersectCount(field, 2)});
    }
}
