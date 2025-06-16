const Clap = @This();

const std = @import("std");

const ClapError = error {
    ModeAlreadySet,
    PositionalAlreadySet,
};

pub const Mode = enum {
    none,
    list,
    add,

    pub fn set(self: *Mode, mode: Mode) ClapError!void {
        if (self.* != .none) {
            return ClapError.ModeAlreadySet;
        }
        self.* = mode;
    }
};

allocator: std.mem.Allocator,
mode: Mode = .none,
help: bool = false,
positional: ?[]const u8 = null,

pub fn init(allocator: std.mem.Allocator) !Clap {
    const args = std.os.argv;

    var mode: Mode = .none;
    var help = false;
    var positional: ?[]const u8 = null;

    for (1..args.len) |i| {
        const arg = args[i];
        if (eql(arg, "--list")) { try mode.set(.list); continue; }
        if (eql(arg, "--add")) { try mode.set(.add); continue; }
        if (eql(arg, "--help")) { help = true; continue; }
        if (positional != null) return ClapError.PositionalAlreadySet;
        positional = try dupe(allocator, arg);
    }
    return .{
        .allocator = allocator,
        .mode = mode,
        .help = help,
        .positional = positional,
    };
}

pub fn deinit(self: *Clap) void {
    if (self.positional) |pos| {
        self.allocator.free(pos);
    }
}

pub fn shouldShowHelp(self: Clap) bool {
    return self.help or (
        self.mode != .list and self.positional == null
    );
}

fn eql(arg: [*:0]u8, match: []const u8) bool {
    for (match, 0..) |c, i| {
        if (arg[i] != c) return false;
    }
    return true;
}

fn dupe(allocator: std.mem.Allocator, arg: [*:0]u8) ![]const u8 {
    var n: usize = 0;
    while (arg[n] != 0): (n += 1) {}
    var duplicate = try allocator.alloc(u8, n);
    for (0..n) |i| {
        duplicate[i] = arg[i];
    }
    return duplicate;
}

pub fn usage(mode: Mode) void {
    switch (mode) {
        .none => std.debug.print(
            \\Usage: rpc <command> [options]

            \\Commands:
            \\  <name>               Show the URL for the saved RPC with the given name
            \\  --add <name>         Add a new RPC endpoint
            \\  --list               List all saved RPC endpoints
            \\
            \\Options:
            \\  --help               Show help for the selected command
            \\
            \\Examples:
            \\  rpc --add eth
            \\  rpc eth
            \\  rpc --list
            \\  rpc --add --help
            \\
        , .{}),
        .add => std.debug.print(
            \\Usage: rpc --add <name>

            \\Adds a new RPC endpoint by name. Prompts interactively for the URL.
            \\Fails if the given name already exists.
            \\
            \\Example:
            \\  rpc --add mainnet
            \\
            \\Notes:
            \\  - Use descriptive names like 'mainnet', 'polygon', or 'local'.
            \\  - URL will be stored for later use via `rpc <name>`.
            \\
        , .{}),
        .list => std.debug.print(
            \\Usage: rpc --list
            \\
            \\Lists all saved RPC endpoints in a table
            \\
            \\Example:
            \\  rpc --list
            \\
        , .{}),
    }
}
