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

    self.skipWhitespace();

    switch (self.ch) {
        '=' => {
            if (self.peekChar() == '=') {
                self.readChar();
                token = Token.init(.eq, "==");
            } else {
                token = Token.init(.assign, "=");
            }
        },
        '!' => {
            if (self.peekChar() == '=') {
                self.readChar();
                token = Token.init(.not_eq, "!=");
            } else {
                token = Token.init(.bang, "!");
            }
        },
        '+' => token = Token.init(.plus, "+"),
        '-' => token = Token.init(.minus, "-"),
        '/' => token = Token.init(.slash, "/"),
        '*' => token = Token.init(.asterisk, "*"),
        '<' => token = Token.init(.lt, "<"),
        '>' => token = Token.init(.gt, ">"),
        ';' => token = Token.init(.semicolon, ";"),
        '(' => token = Token.init(.lparen, "("),
        ')' => token = Token.init(.rparen, ")"),
        ',' => token = Token.init(.comma, ","),
        '{' => token = Token.init(.lbrace, "{"),
        '}' => token = Token.init(.rbrace, "}"),
        0 => token = Token.init(.eof, ""),
        else => {
            if (isLetter(self.ch)) {
                token.literal = self.readIdentifier();
                token.token_type = Token.lookupIdentifier(token.literal);
                return token;
            } else if (isDigit(self.ch)) {
                token.literal = self.readNumber();
                token.token_type = .integer;
                return token;
            } else {
                token = Token.init(.illegal, "");
            }
        },
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

fn peekChar(self: *Lexer) u8 {
    if (self.read_position < self.input.len) {
        return self.input[self.read_position];
    } else {
        return 0;
    }
}

fn readIdentifier(self: *Lexer) []const u8 {
    const position = self.position;
    while (isLetter(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn readNumber(self: *Lexer) []const u8 {
    const position = self.position;
    while (isDigit(self.ch)) {
        self.readChar();
    }
    return self.input[position..self.position];
}

fn skipWhitespace(self: *Lexer) void {
    while (std.ascii.isWhitespace(self.ch)) {
        self.readChar();
    }
}

fn isLetter(ch: u8) bool {
    return std.ascii.isAlphabetic(ch) or ch == '_';
}

fn isDigit(ch: u8) bool {
    return std.ascii.isDigit(ch);
}

test Lexer {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\	x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
    ;

    const tests = [_]Token{
        Token.init(.keyword_let, "let"),
        Token.init(.identifier, "five"),
        Token.init(.assign, "="),
        Token.init(.integer, "5"),
        Token.init(.semicolon, ";"),
        Token.init(.keyword_let, "let"),
        Token.init(.identifier, "ten"),
        Token.init(.assign, "="),
        Token.init(.integer, "10"),
        Token.init(.semicolon, ";"),

        Token.init(.keyword_let, "let"),
        Token.init(.identifier, "add"),
        Token.init(.assign, "="),
        Token.init(.keyword_function, "fn"),
        Token.init(.lparen, "("),
        Token.init(.identifier, "x"),
        Token.init(.comma, ","),
        Token.init(.identifier, "y"),
        Token.init(.rparen, ")"),
        Token.init(.lbrace, "{"),
        Token.init(.identifier, "x"),
        Token.init(.plus, "+"),
        Token.init(.identifier, "y"),
        Token.init(.semicolon, ";"),
        Token.init(.rbrace, "}"),
        Token.init(.semicolon, ";"),

        Token.init(.keyword_let, "let"),
        Token.init(.identifier, "result"),
        Token.init(.assign, "="),
        Token.init(.identifier, "add"),
        Token.init(.lparen, "("),
        Token.init(.identifier, "five"),
        Token.init(.comma, ","),
        Token.init(.identifier, "ten"),
        Token.init(.rparen, ")"),
        Token.init(.semicolon, ";"),

        Token.init(.bang, "!"),
        Token.init(.minus, "-"),
        Token.init(.slash, "/"),
        Token.init(.asterisk, "*"),
        Token.init(.integer, "5"),
        Token.init(.semicolon, ";"),
        Token.init(.integer, "5"),
        Token.init(.lt, "<"),
        Token.init(.integer, "10"),
        Token.init(.gt, ">"),
        Token.init(.integer, "5"),
        Token.init(.semicolon, ";"),

        Token.init(.keyword_if, "if"),
        Token.init(.lparen, "("),
        Token.init(.integer, "5"),
        Token.init(.lt, "<"),
        Token.init(.integer, "10"),
        Token.init(.rparen, ")"),
        Token.init(.lbrace, "{"),
        Token.init(.keyword_return, "return"),
        Token.init(.keyword_true, "true"),
        Token.init(.semicolon, ";"),
        Token.init(.rbrace, "}"),
        Token.init(.keyword_else, "else"),
        Token.init(.lbrace, "{"),
        Token.init(.keyword_return, "return"),
        Token.init(.keyword_false, "false"),
        Token.init(.semicolon, ";"),
        Token.init(.rbrace, "}"),

        Token.init(.integer, "10"),
        Token.init(.eq, "=="),
        Token.init(.integer, "10"),
        Token.init(.semicolon, ";"),
        Token.init(.integer, "10"),
        Token.init(.not_eq, "!="),
        Token.init(.integer, "9"),
        Token.init(.semicolon, ";"),

        Token.init(.eof, ""),
    };
    var lexer = init(input);

    for (tests) |expect| {
        const token = lexer.nextToken();

        try std.testing.expectEqual(expect.token_type, token.token_type);
        try std.testing.expectEqualSlices(u8, expect.literal, token.literal);
    }
}
