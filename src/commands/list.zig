const std = @import("std");
const Clap = @import("../lib/clap.zig");
const Config = @import("../lib/config.zig");

const stdout = std.io.getStdOut().writer();

pub fn run(config: Config) !void {
    var max_name_len: usize = 0;
    for (config.list.items) |item| {
        max_name_len = @max(max_name_len, item.name.len);
    }
    for (config.list.items) |item| {
        const padding: u8 = @truncate(max_name_len - item.name.len);
        var spaces: [256]u8 = undefined;
        @memset(spaces[0..padding], ' ');
        try stdout.print("- {s}{s}: {s}\n", .{ item.name, spaces[0..padding], item.url});
    }
}
