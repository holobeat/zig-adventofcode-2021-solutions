const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn readFile(allocator: Allocator, filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var buff = try file.readToEndAlloc(allocator, stat.size);
    return buff;
}
