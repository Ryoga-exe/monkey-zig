const Token = @This();

token_type: TokenType,
literal: []const u8,

const TokenType = enum {
    illegal,
    eof,

    // Identifier and Literal
    ident,
    int,

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
