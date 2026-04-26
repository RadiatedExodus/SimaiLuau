--!strict
local TokenType = require("./TokenType")

--// this certainly didn't need to be made a class (a simple table with type would do)
--// but lets just make it a class :+1:

local Token = {}
Token.__index = Token

export type Token = setmetatable<{
    Type:      TokenType.TokenType,
    Lexeme:    string,
    Line:      number,
    Character: number,
}, typeof(Token)>

return {
    new = function(type: TokenType.TokenType, lexeme: string, line: number, character: number): Token
        return setmetatable({
            Type      = type,
            Lexeme    = lexeme,
            Line      = line,
            Character = character,
        }, Token)
    end
}