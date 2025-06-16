const std = @import("std");
const Config = @import("../lib/config.zig");
const Clap = @import("../lib/clap.zig");

const stdout_handle = std.io.getStdOut();
const stdout = stdout_handle.writer();
const stdin = std.io.getStdIn().reader();

pub fn run(config: *Config, name: []const u8) !void {
    try stdout.print("RPC URL for {s}? ", .{name});
    try config.file.seekFromEnd(0);
    var line_buf: [2048]u8 = undefined;
    const url = try stdin.readUntilDelimiter(&line_buf, '\n');
    const line = try std.fmt.allocPrint(config.allocator, "{s}|{s}\n", .{ name, url });
    defer config.allocator.free(line);
    try config.file.writeAll(line);
}
