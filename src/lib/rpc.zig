const RPC = @This();

const std = @import("std");

pub const List = std.ArrayList(RPC);

allocator: std.mem.Allocator,
name: []const u8,
url: []const u8,

pub fn init(allocator: std.mem.Allocator, name: []const u8, url: []const u8) !RPC {
    return .{
        .allocator = allocator,
        .name = try allocator.dupe(u8, name),
        .url = try allocator.dupe(u8, url),
    };
}

pub fn deinit(self: *RPC) void {
    self.allocator.free(self.name);
    self.allocator.free(self.url);
}
