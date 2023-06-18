
const std = @import("std");

fn generate(ch: *u32) void {
    var i: u32 = 2;
    while (true): (i += 1) {
        ch.* = i;
        suspend {}
    }
}

fn filter(fr1: anyframe, ch1: *u32, ch2: *u32, prime: u32) void {
    while (true) {
        var i: u32 = ch1.*;
        resume fr1;
        if (i % prime != 0) {
            ch2.* = i;
            suspend {}
        }
    }
}


pub fn main(argc: isize, argv: [][]const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit():
    const allocator = arena.allocator();

    var n: u32 = 100;
    if (argc >= 2) {
        n = try std.fmt.parseInt(u32, argv[1], 10);
    }

    var ch = try allocator.alloc(u32, n);
    var fr = try allocator.alloc(@Frame(filter), n);

    fr[0] = async generate(&ch[0]);
    
    var i: usize = 0;
    while (true) {
        const prime: u32 = ch[i];
        resume fr[i];
        _ = std.c.printf("%d\n", .{prime});
        if (i == n-1) break;
        fr[i+1] = async filter(fr[i], &ch[i], &ch[i+1], prime);
        i += 1;
    }
}

