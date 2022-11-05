const std = @import("std");
const parser = @import("./parser.zig");
const testing = std.testing;

const key = @import("./key.zig");
const value = @import("./value.zig");
const spaces = @import("./spaces.zig");

pub const KeyValuePair = struct {
    key: key.Key,
    value: value.Value,

    pub fn deinit(self: *KeyValuePair, ctx: *parser.Context) void {
        self.key.deinit(ctx);
        self.value.deinit(ctx);
    }
};

pub fn parse(ctx: *parser.Context) !KeyValuePair {
    var k = try key.parse(ctx);
    spaces.skipSpaces(ctx);
    try parser.consumeString(ctx, "=");
    spaces.skipSpaces(ctx);
    var v = try value.parse(ctx);
    return KeyValuePair{
        .key = k,
        .value = v,
    };
}

test "key value pair" {
    var ctx = parser.testInput(
        \\abc = "aa"
    );
    var kv = try parse(&ctx);
    try testing.expect(std.mem.eql(u8, kv.key.bare.content, "abc"));
    try testing.expect(std.mem.eql(u8, kv.value.string, "aa"));
    kv.deinit(&ctx);
}
