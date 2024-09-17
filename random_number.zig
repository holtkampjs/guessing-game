const std = @import("std");

fn get_random_number() !u8 {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const rand = prng.random();

    return rand.intRangeAtMost(u8, 0, 100);
}

pub fn main() !void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());
    var r = buf.reader();

    const num = try get_random_number();

    std.debug.print("Random number: {d}\n", .{num});

    var msg_buf: [4096]u8 = undefined;

    while (true) {
        std.debug.print("Guess the number [0-100]: ", .{});
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        var guess: u8 = undefined;
        if (msg) |m| {
            guess = try std.fmt.parseInt(u8, m, 10);
        }

        if (guess == num) {
            std.debug.print("Hooray! You got it right!\n", .{});
            break;
        } else {
            std.debug.print("Wrong. Try again.\n", .{});
        }
    }
}
