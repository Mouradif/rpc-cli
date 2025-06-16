const Config = @This();

const std = @import("std");

const RPC = @import("./rpc.zig");

allocator: std.mem.Allocator,
file: std.fs.File,
list: RPC.List,

fn getConfigPath(allocator: std.mem.Allocator) ![]u8 {
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();
    const config_home = env.get("XDG_CONFIG_HOME") orelse {
        const home = env.get("HOME") orelse return error.NoHomeDirectory;
        return std.fs.path.join(allocator, &[_][]const u8{ home, ".config", "rpc", "list" });
    };
    return std.fs.path.join(allocator, &[_][]const u8{ config_home, "rpc", "list" });
}

fn getConfigFile(allocator: std.mem.Allocator) !std.fs.File {
    const config_path = try getConfigPath(allocator);
    defer allocator.free(config_path);
    const path = std.fs.path.dirname(config_path) orelse return error.InvalidPath;
    try std.fs.cwd().makePath(path);
    const file = std.fs.cwd().openFile(config_path, .{ .mode = .read_write }) catch |err| switch (err) {
        error.FileNotFound => blk: {
            const new_file = try std.fs.cwd().createFile(config_path, .{});
            break :blk new_file;
        },
        else => return err,
    };
    return file;
}

pub fn init(allocator: std.mem.Allocator) !Config {
    const file = try getConfigFile(allocator);
    var list = RPC.List.init(allocator);
    errdefer list.deinit();
    const file_content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_content);
    var lines = std.mem.tokenizeScalar(u8, file_content, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len == 0) continue;
        var parts = std.mem.splitScalar(u8, trimmed, '|');
        const name = parts.next() orelse continue;
        const url = parts.next() orelse continue;
        if (parts.next()) |_| continue;

        const rpc = try RPC.init(allocator, std.mem.trim(u8, name, " \t\r"), std.mem.trim(u8, url, " \t\r"));
        try list.append(rpc);
    }
    return .{
        .allocator = allocator,
        .file = file,
        .list = list,
    };
}

pub fn deinit(self: *Config) void {
    for (self.list.items) |*item| {
        item.deinit();
    }
    self.list.deinit();
    self.file.close();
}
