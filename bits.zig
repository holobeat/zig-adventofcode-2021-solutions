const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var n: u12 = 0b101101111010;
    const p = [_]u8{11};
    print("{d}\n", .{(n >> p[0]) & 1});
}