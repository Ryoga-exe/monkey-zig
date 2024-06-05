const std = @import("std");
const Lexer = @This();
const Token = @import("token.zig");

input: []const u8,
position: usize,
read_position: usize,
ch: u8,

pub fn init(input: []const u8) Lexer {
    var self = Lexer{
        .input = input,
        .position = 0,
        .read_position = 0,
        .ch = 0,
    };
    self.readChar();
    return self;
}

pub fn nextToken(self: *Lexer) Token {
    var token = Token.init(.illegal, "");

    switch (self.ch) {
        '=' => token = Token.init(.assign, "="),
        ';' => token = Token.init(.semicolon, ";"),
        '(' => token = Token.init(.lparen, "("),
        ')' => token = Token.init(.rparen, ")"),
        ',' => token = Token.init(.comma, ","),
        '+' => token = Token.init(.plus, "+"),
        '{' => token = Token.init(.lbrace, "{"),
        '}' => token = Token.init(.rbrace, "}"),
        0 => token = Token.init(.eof, ""),
        else => token = Token.init(.illegal, ""),
    }
    self.readChar();

    return token;
}

fn readChar(self: *Lexer) void {
    if (self.read_position < self.input.len) {
        self.ch = self.input[self.read_position];
    } else {
        self.ch = 0;
    }
    self.position = self.read_position;
    self.read_position += 1;
}

fn skipWhitespace(self: *Lexer) void {
    while (std.ascii.isWhitespace(self.ch)) {
        self.readChar();
    }
}

test Lexer {
    const input =
        \\=+(){},;
    ;

    const tests = [_]Token{
        Token.init(.assign, "="),
        Token.init(.plus, "+"),
        Token.init(.lparen, "("),
        Token.init(.rparen, ")"),
        Token.init(.lbrace, "{"),
        Token.init(.rbrace, "}"),
        Token.init(.comma, ","),
        Token.init(.semicolon, ";"),
    };
    var lexer = init(input);

    for (tests) |expect| {
        const token = lexer.nextToken();

        try std.testing.expectEqual(expect.token_type, token.token_type);
        try std.testing.expectEqualSlices(u8, expect.literal, token.literal);
    }
}
