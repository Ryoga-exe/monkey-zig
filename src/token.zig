const std = @import("std");
const Token = @This();

token_type: TokenType,
literal: []const u8,

const TokenType = enum {
    illegal,
    eof,

    // Identifier and Literal
    identifier,
    integer,

    // Operator
    assign,
    plus,

    // Delimiter
    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    // Keywords
    function,
    let,
};

pub fn init(token_type: TokenType, literal: []const u8) Token {
    return Token{
        .token_type = token_type,
        .literal = literal,
    };
}

pub fn lookupIdentifier(identifier: []const u8) TokenType {
    const map = std.ComptimeStringMap(TokenType, .{
        .{ "fn", .function },
        .{ "let", .let },
    });
    if (map.get(identifier)) |key| {
        return key;
    }
    return .identifier;
}
