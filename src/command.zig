const Clap = @import("./lib/clap.zig");
const Config = @import("./lib/config.zig");
const ListCommand = @import("./commands/list.zig");
const AddCommand = @import("./commands/add.zig");
const FetchCommand = @import("./commands/fetch.zig");

const std = @import("std");
const fs = std.fs;

pub fn process(allocator: std.mem.Allocator, clap: Clap) !void {
    var config = try Config.init(allocator);
    defer config.deinit();

    switch (clap.mode) {
        .list => try ListCommand.run(config),
        .add => try AddCommand.run(&config, clap.positional.?),
        .none => try FetchCommand.run(config, clap.positional.?),
    }
}
