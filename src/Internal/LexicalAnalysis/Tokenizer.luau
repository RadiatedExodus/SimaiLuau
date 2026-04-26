--!strict
local Token     = require("./Token")
local TokenType = require("./TokenType")

local SPACE               = utf8.char(0x0020)
local EN_SPACE            = utf8.char(0x2002)
local PUNCTUATION_SPACE   = utf8.char(0x2008)
local IDEOGRAPHIC_SCORE   = utf8.char(0x3000)
local LINE_SEPERATOR      = utf8.char(0x2028)
local PARAGRAPH_SEPERATOR = utf8.char(0x2029)
local END_OF_FILE_CHAR    = "E"

local EACH_DIVIDER_CHARS = {"/", "`"}
local DECORATOR_CHARS    = {"f", "b", "x", "h", "m", "!", "?", "@", "$"}
local SLIDE_CHARS        = {"-", ">", "<", "^", "p", "q", "v", "V", "s", "z", "w"}
local SEPARATOR_CHARS    = {"\r", "\t", LINE_SEPERATOR, PARAGRAPH_SEPERATOR, SPACE, EN_SPACE, PUNCTUATION_SPACE, IDEOGRAPHIC_SCORE}

local Tokenizer = {}
Tokenizer.__index = Tokenizer

export type Tokenizer = setmetatable<{
    __Sequence:  string,
    __Current:   number,
    __CharIndex: number,
    __Line:      number,
    __Start:     number,
}, typeof(Tokenizer)>

function Tokenizer.__IsAtEnd(self: Tokenizer): boolean
    return (self.__Current > #self.__Sequence)
end

function Tokenizer.GetTokens(self: Tokenizer): {Token.Token}
    local t = {} :: {Token.Token}
    while (not self:__IsAtEnd()) do
        self.__Start = self.__Current
        local token = self:__ScanToken()
        if (token ~= nil) then
            table.insert(t, token)
        end
    end
    return t
end

function Tokenizer.__ScanToken(self: Tokenizer): Token.Token?
    self.__CharIndex += 1
    local c = self:__Advance()

    if     (c == ",") then
        return self:__CompileToken(TokenType.TimeStep)
    elseif (c == "(") then
        return self:__CompileSectionToken(TokenType.Tempo, "(", ")")
    elseif (c == "{") then
        return self:__CompileSectionToken(TokenType.Subdivision, "{", "}")
    elseif (c == "[") then
        return self:__CompileSectionToken(TokenType.Duration, "[", "]")
    end

    local locToken, locTokenLength = self:__TryScanLocationToken()
    if (locToken) then
        self.__Current += locTokenLength - 1
        return self:__CompileToken(TokenType.Location)
    end

    if (table.find(DECORATOR_CHARS, c) ~= nil) then
        return self:__CompileToken(TokenType.Decorator)
    end

    local slideDecl, slideDeclLength = self:__IsReadingSlideDeclaration()
    if (slideDecl) then
        self.__Current += slideDeclLength - 1
        return self:__CompileToken(TokenType.Slide)
    end

    if (c == "*") then
        return self:__CompileToken(TokenType.SlideJoiner)
    elseif (table.find(EACH_DIVIDER_CHARS, c) ~= nil) then
        return self:__CompileToken(TokenType.EachDivider)
    elseif (table.find(SEPARATOR_CHARS, c) ~= nil) then
        return nil
    elseif (c == "\n") then
        self.__Line += 1
        self.__CharIndex = 0
        return nil
    elseif (c == "E") then
        return self:__CompileToken(TokenType.EndOfFile)
    elseif (c == "|") then
        assert(self:__Peek() == "|", `unexpected character at {self.__Line}@{self.__CharIndex}, expected |`)
        while (self:__Peek() ~= "\n") and (not self:__IsAtEnd()) do
            self:__Advance()
        end
        return nil
    end

    assert(false, `unsupported syntax at {self.__Line}@{self.__CharIndex}`)
end

function Tokenizer.__TryScanLocationToken(self: Tokenizer): (boolean, number)
    local firstLocationChar = self:__PeekPrevious()

    if (self:__IsButtonLocation(firstLocationChar)) then
        return true, 1
    end

    if (not self:__IsSensorLocation(firstLocationChar)) then
        return false, 0
    end

    local secondLocationChar = self:__Peek()

    if (self:__IsButtonLocation(secondLocationChar)) then
        return true, 2
    end

    if (firstLocationChar == "C") then
        return true, 1
    end

    local secondCharIsEmpty = (table.find(SEPARATOR_CHARS, secondLocationChar) ~= nil) or (secondLocationChar == '\n') or (secondLocationChar == "\0")
    if ((firstLocationChar == END_OF_FILE_CHAR) and secondCharIsEmpty) then
        return false, 0
    end

    assert(false, `unexpected character at {self.__Line}@{self.__CharIndex}, expected 1, 2, 3, 4, 5, 6, 7, 8`)
end

function Tokenizer.__IsReadingSlideDeclaration(self: Tokenizer): (boolean, number)
    if (table.find(SLIDE_CHARS, self:__PeekPrevious()) == nil) then
        return false, 0
    end
    local nextChar = self:__Peek()
    return true, (if (nextChar == "p") or (nextChar == "q") then 2 else 1)
end

function Tokenizer.__CompileSectionToken(self: Tokenizer, tokenType: TokenType.TokenType, initiator: string, terminator: string): Token.Token?
    self.__Start += 1

    while (self:__Peek() ~= terminator) do
        assert(not (self:__IsAtEnd() or (self:__Peek() == initiator)), `unterminated section at {self.__Line}@{self.__CharIndex}`)
        self:__Advance()
    end

    local token = self:__CompileToken(tokenType)
    self:__Advance()
    return token
end

function Tokenizer.__CompileToken(self: Tokenizer, type: TokenType.TokenType): Token.Token
    --// string.sub(self.__Sequence, self.__Start, self.__Current)
    return Token.new(type, string.sub(self.__Sequence, self.__Start, self.__Current - 1), self.__Line, self.__CharIndex)
end

function Tokenizer.__IsSensorLocation(self: Tokenizer, value: string): boolean
    return (value >= "A") and (value <= "E")
end

function Tokenizer.__IsButtonLocation(self: Tokenizer, value: string): boolean
    return (value >= "0") and (value <= "8")
end

function Tokenizer.__Advance(self: Tokenizer): string
    local o = string.sub(self.__Sequence, self.__Current, self.__Current)
    self.__Current += 1
    return o
end

function Tokenizer.__Peek(self: Tokenizer): string
    return if (self:__IsAtEnd()) then "\0" else string.sub(self.__Sequence, self.__Current, self.__Current)
end

function Tokenizer.__PeekPrevious(self: Tokenizer): string
    return if (self.__Current == 1) then "\0" else string.sub(self.__Sequence, self.__Current - 1, self.__Current - 1)
end

return {
    new = function(sequence: string): Tokenizer
        return setmetatable({
            __Sequence  = sequence,
            __Current   = 1,
            __CharIndex = 0,
            __Line      = 1,
            __Start     = 1,
        }, Tokenizer)
    end
}