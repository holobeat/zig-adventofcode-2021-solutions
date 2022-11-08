// --- Day 4: Giant Squid ---
// You're already almost 1.5km (almost a mile) below the surface of the ocean,
// already so deep that you can't see any sunlight. What you can see, however,
// is a giant squid that has attached itself to the outside of your submarine.
//
// Maybe it wants to play bingo?
//
// Bingo is played on a set of boards each consisting of a 5x5 grid of numbers.
// Numbers are chosen at random, and the chosen number is marked on all boards
// on which it appears. (Numbers may not appear on all boards.) If all numbers
// in any row or any column of a board are marked, that board wins. (Diagonals
// don't count.)
//
// The submarine has a bingo subsystem to help passengers (currently, you and
// the giant squid) pass the time. It automatically generates a random order in
// which to draw numbers and a random set of boards (your puzzle input).
//
// For example:
//
// 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
//
// 22 13 17 11  0
//  8  2 23  4 24
// 21  9 14 16  7
//  6 10  3 18  5
//  1 12 20 15 19
//
//  3 15  0  2 22
//  9 18 13 17  5
// 19  8  7 25 23
// 20 11 10 24  4
// 14 21 16 12  6
//
// 14 21 17 24  4
// 10 16 15  9 19
// 18  8 23 26 20
// 22 11 13  6  5
//  2  0 12  3  7
//
// After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no
// winners, but the boards are marked as follows (shown here adjacent to each
// other to save space):
//
// 22 13 17*11  0         3 15  0  2 22        14 21 17 24 *4
//  8  2 23 *4 24        *9 18 13 17 *5        10 16 15 *9 19
// 21 *9 14 16 *7        19  8 *7 25 23        18  8 23 26 20
//  6 10  3 18 *5        20*11 10 24 *4        22*11 13  6 *5
//  1 12 20 15 19        14 21 16 12  6         2  0 12  3 *7
//
// After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are
// still no winners:
//
// 22 13*17*11 *0         3 15 *0 *2 22       *14*21*17 24 *4
//  8 *2*23 *4 24        *9 18 13*17 *5        10 16 15 *9 19
//*21 *9*14 16 *7        19  8 *7 25*23        18  8*23 26 20
//  6 10  3 18 *5        20*11 10 24 *4        22*11 13  6 *5
//  1 12 20 15 19       *14*21 16 12  6        *2 *0 12  3 *7
//
// Finally, 24 is drawn:
//
// 22 13*17*11 *0         3 15 *0 *2 22       *14*21*17*24 *4
//  8 *2*23 *4*24        *9 18 13*17 *5        10 16 15 *9 19
//*21 *9*14 16 *7        19  8 *7 25*23        18  8*23 26 20
//  6 10  3 18 *5        20*11 10*24 *4        22*11 13  6 *5
//  1 12 20 15 19       *14*21 16 12  6        *2 *0 12  3 *7
//
// At this point, the third board wins because it has at least one complete row
// or column of marked numbers (in this case, the entire top row
// is marked: 14 21 17 24 4).
//
// The score of the winning board can now be calculated. Start by finding the
// sum of all unmarked numbers on that board; in this case, the sum is 188.
// Then, multiply that sum by the number that was just called when the board
// won, 24, to get the final score, 188 * 24 = 4512.
//
// To guarantee victory against the giant squid, figure out which board will
// win first. What will your final score be if you choose that board?
//
// --- Part Two ---
// On the other hand, it might be wise to try a different strategy: let
// the giant squid win.
//
// You aren't sure how many bingo boards a giant squid could play at once,
// so rather than waste time counting its arms, the safe thing to do is to
// figure out which board will win last and choose that one. That way, no
// matter which boards it picks, it will win for sure.
//
// In the above example, the second board is the last to win, which happens
// after 13 is eventually called and its middle column is completely marked.
// If you were to keep playing until this point, the second board would have
// a sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.
//
// Figure out which board will win last. Once it wins, what would its final
// score be?

const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const utils = @import("utils.zig");

const Slot = struct {
    number: u8 = 0,
    marked: bool = false,
};

const Board = struct {
    slots: [25]Slot,

    pub fn checkWinWith(self: *Board, number: u8) ?usize {
        const rs = [_]u8{ 0, 5, 10, 15, 20 };
        var mc: u8 = 0;

        // winning row check
        for (rs) |i| {
            var x: u8 = 0;
            while (x < 5) : (x += 1) {
                if (self.slots[i + x].marked) mc += 1;
            }
            if (mc == 5) return self.sumUnmarked() * number;
            mc = 0;
        }
        // winning column check
        var col: u8 = 0;
        while (col < 5) {
            var y: u8 = 0;
            while (y < 5) : (y += 1) {
                if (self.slots[y * 5 + col].marked) {
                    mc += 1;
                }
            }
            if (mc == 5) return self.sumUnmarked() * number;
            mc = 0;
            col += 1;
        }
        return null;
    }

    fn sumUnmarked(self: *Board) usize {
        var c: usize = 0;
        for (self.slots) |s| {
            if (!s.marked) c += s.number;
        }
        return c;
    }

    pub fn result() usize {}
};

const DrawNumbers = struct {
    numbers: ArrayList(u8) = undefined,

    pub fn init(allocator: Allocator, buff: []const u8) !DrawNumbers {
        var nums = ArrayList(u8).init(allocator);
        var str_num = std.mem.split(u8, buff, ",");
        while (str_num.next()) |n| {
            var p = try std.fmt.parseInt(u8, n, 10);
            try nums.append(p);
        }
        return DrawNumbers{ .numbers = nums };
    }

    pub fn deinit(self: *DrawNumbers) void {
        self.numbers.deinit();
    }
};

fn nextBoard(comptime T: type, iter: *std.mem.SplitIterator(T)) !?Board {
    var board = Board{ .slots = undefined };
    var counter: u8 = 0;

    while (iter.next()) |line| {
        if (line.len == 0) continue;
        var str_nums = std.mem.split(u8, line, " ");
        while (str_nums.next()) |s| {
            if (s.len > 0) {
                board.slots[counter] = Slot{ .number = try std.fmt.parseInt(u8, s, 10) };
                counter += 1;
                if (counter == 25) return board;
            }
        }
    }

    return null;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var buff = try utils.readFile(allocator, "day04_input.txt");
    defer allocator.free(buff);

    var lines = std.mem.split(u8, buff, "\n");
    var line = lines.next() orelse "";

    // load drawing numbers
    var draw = try DrawNumbers.init(allocator, line);
    defer draw.deinit();

    // load boards
    var boards = ArrayList(Board).init(allocator);
    while (try nextBoard(u8, &lines)) |board| {
        boards.append(board) catch unreachable;
    }

    // update the boards with the drawn numbers
    update: for (draw.numbers.items) |n| {
        for (boards.items) |*board| {
            for (board.*.slots) |*slot| {
                if (n == slot.number) {
                    slot.*.marked = true;
                    if (board.checkWinWith(n)) |result| {
                        print("\nWinning board:\n", .{});
                        printBoard(board.*);
                        print("\nSolution: {d}\n", .{ result });
                        break :update;
                    }
                }
            }
        }
    }
    print("\n", .{});
}

fn printBoard(board: Board) void {
    var r: u8 = 0;
    for (board.slots) |s| {
        r += 1;
        print(
            "{s:2}{d:2} |{s}",
            .{
                if (s.marked) "*" else " ",
                s.number,
                if (r == 5) "\n" else "",
            },
        );
        if (r == 5) r = 0;
    }
}
