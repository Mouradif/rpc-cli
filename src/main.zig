const std = @import("std");
const Clap = @import("./lib/clap.zig");
const Command = @import("./command.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var clap = try Clap.init(allocator);
    defer clap.deinit();
    if (clap.shouldShowHelp()) {
        return Clap.usage(clap.mode);
    }
    try Command.process(allocator, clap);
}
