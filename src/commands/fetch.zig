const std = @import("std");
const Config = @import("../lib/config.zig");

const stdout_handle = std.io.getStdOut();
const stdout = stdout_handle.writer();

pub fn run(config: Config, name: []const u8) !void {
    for (config.list.items) |item| {
        if (std.mem.eql(u8, item.name, name)) {
            try stdout.print("{s}", .{ item.url });
            if (stdout_handle.isTty()) {
                try stdout.print("\n", .{});
            }
            return;
        }
    }
}
