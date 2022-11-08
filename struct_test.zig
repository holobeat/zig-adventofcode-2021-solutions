const std = @import("std");

const DrawNumbers = struct {
    x: usize,
    y: usize,
    n: std.ArrayList(u8) = undefined,

    pub fn init() DrawNumbers {
        return .{ .x = 10, .y = 10 };
    }

    // pub fn deinit(self: *DrawNumbers) void {
    //     self.numbers.deinit();
    // }
};

pub fn main() void {
    // _ = DrawNumbers{.x = 0, .y = 0};
    _ = DrawNumbers.init();
}
