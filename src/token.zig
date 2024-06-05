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
    minus,
    bang,
    asterisk,
    slash,
    lt,
    gt,

    // Delimiter
    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    // Keywords
    keyword_function,
    keyword_let,
    keyword_true,
    keyword_false,
    keyword_if,
    keyword_else,
    keyword_return,
};

pub fn init(token_type: TokenType, literal: []const u8) Token {
    return Token{
        .token_type = token_type,
        .literal = literal,
    };
}

pub fn lookupIdentifier(identifier: []const u8) TokenType {
    const map = std.ComptimeStringMap(TokenType, .{
        .{ "fn", .keyword_function },
        .{ "let", .keyword_let },
        .{ "true", .keyword_true },
        .{ "false", .keyword_false },
        .{ "if", .keyword_if },
        .{ "else", .keyword_else },
        .{ "return", .keyword_return },
    });
    if (map.get(identifier)) |key| {
        return key;
    }
    return .identifier;
}
