--!strict
local TimingChange = require("../TimingChange")
local Extensions   = require("../../Extensions")
local Token        = require("../../LexicalAnalysis/Token")
local TokenType    = require("../../LexicalAnalysis/TokenType")
local Location     = require("../../../Structures/Location")
local Note         = require("../../../Structures/Note")
local SlidePath    = require("../../../Structures/SlidePath")
local NoteType     = require("../../../Structures/NoteType")
local SlideSegment = require("../../../Structures/SlideSegment")
local SlideType    = require("../../../Structures/SlideType")

local function DecorateSlide(token: Token.Token, path: SlidePath.SlidePath)
    local firstChar = string.sub(token.Lexeme, 1, 1)
    assert(firstChar == "b", `unsupported syntax at {token.Line}@{token.Character}`)
    path.Type = NoteType.Break
    return
end

local function IdentifySlideType(identityToken: Token.Token, startingLocation: Location.Location, segment: SlideSegment.SlideSegment, length: number): SlideType.SlideType
    local type       = (nil :: any) :: SlideType.SlideType
    local firstChar  = string.sub(identityToken.Lexeme, 1, 1)
    local secondChar = string.sub(identityToken.Lexeme, 2, 2)

    if     (firstChar == "-") then
        type = SlideType.StraightLine
    elseif (firstChar == ">") then
        type = Extensions.DetermineRingType(startingLocation, segment.Vertices[1], 1)
    elseif (firstChar == "<") then
        type = Extensions.DetermineRingType(startingLocation, segment.Vertices[1], -1)
    elseif (firstChar == "^") then
        type = Extensions.DetermineRingType(startingLocation, segment.Vertices[1], 0)
    elseif (firstChar == "q") and (length == 2) and (secondChar == "q") then
        type = SlideType.EdgeCurveCw
    elseif (firstChar == "q") then
        type = SlideType.CurveCw
    elseif (firstChar == "p") and (length == 2) and (secondChar == "p") then
        type = SlideType.EdgeCurveCcw
    elseif (firstChar == "p") then
        type = SlideType.CurveCcw
    elseif (firstChar == "v") then
        type = SlideType.Fold
    elseif (firstChar == "V") then
        type = SlideType.EdgeFold
    elseif (firstChar == "s") then
        type = SlideType.ZigZagS
    elseif (firstChar == "z") then
        type = SlideType.ZigZagZ
    elseif (firstChar == "w") then
        type = SlideType.Fan
    end

    assert(type ~= nil, `unexpected character at {identityToken.Line}@{identityToken.Character}, expected -, >, <, ^, q, p, v, V, s, z, w`)
    return type
end

local function AssignVertices(parent: any, identityToken: Token.Token, segment: SlideSegment.SlideSegment)
    repeat
        parent.CurrentIndex += 1

        local current = parent.Tokens[parent.CurrentIndex]
        assert(current, `unexpected character at {identityToken.Line}@{identityToken.Character}, expected 1, 2, 3, 4, 5, 6, 7, 8`)

        local readLoc, location = Extensions.TryReadLocation(current)
        if (readLoc) then
            table.insert(segment.Vertices, location)
        end
    until current.Type ~= TokenType.Location
    return
end

local function ReadDuration(timing: TimingChange.TimingChange, token: Token.Token, path: SlidePath.SlidePath)
    local startOfDurationDeclaration = 1
    local overrideTiming             = Extensions.CloneTimingChange(timing)

    local firstHashIndex           = string.find(token.Lexeme, "#") :: number
    local statesIntroDelayDuration = firstHashIndex ~= nil
    if (statesIntroDelayDuration) then
        startOfDurationDeclaration = (Extensions.StringLastIndexOf(token.Lexeme, "#") :: number) + 1
        local lastHashIndex        = startOfDurationDeclaration - 1
        local delayDeclaration     = string.sub(token.Lexeme, 1, firstHashIndex - 1)
        local isExplicitStatement  = firstHashIndex ~= lastHashIndex

        local delayValue = tonumber(delayDeclaration)
        assert(delayValue, `unexpected character at {token.Line}@{token.Character}, expected 0~9 or "."`)

        if (isExplicitStatement) then
            path.Delay = delayValue
        else
            overrideTiming.Tempo = delayValue
            path.Delay           = overrideTiming:SecondsPerBar()
        end
    end

    local durationDeclaration = string.sub(token.Lexeme, startOfDurationDeclaration)
    local indexOfSeparator    = string.find(durationDeclaration, ":")

    if (indexOfSeparator == nil) then
        local explicitValue = tonumber(durationDeclaration)
        assert(explicitValue, `unexpected character at {token.Line}@{token.Character + startOfDurationDeclaration - 1}, expected 0~9, or "."`)

        path.Duration += explicitValue
        return
    end

    local nominator = tonumber(string.sub(durationDeclaration, 1, indexOfSeparator - 1))
    assert(nominator, `unexpected character at {token.Line}@{token.Character + startOfDurationDeclaration - 1}, expected 0~9, or "."`)

    local denominator = tonumber(string.sub(durationDeclaration, indexOfSeparator + 1))
    assert(denominator, `unexpected character at {token.Line}@{token.Character + startOfDurationDeclaration + indexOfSeparator - 1}, expected 0~9, or "."`)

    path.Duration += overrideTiming:SecondsPerBar() / (nominator / 4) * denominator

    return
end

local function ReadSegment(parent: any, identityToken: Token.Token, startingLocation: Location.Location, path: SlidePath.SlidePath)
    local segment = SlideSegment.new({})
    local length  = #identityToken.Lexeme
    AssignVertices(parent, identityToken, segment)
    segment.SlideType = IdentifySlideType(identityToken, startingLocation, segment, length)
    table.insert(path.Segments, segment)
    return
end

local function Process(parent: any, currentNote: Note.Note, identityToken: Token.Token, defaultTimingChange: TimingChange.TimingChange): SlidePath.SlidePath
    local path = SlidePath.new({})
    path.Delay = defaultTimingChange:SecondsPerBeat()
    ReadSegment(parent, identityToken, currentNote.Location, path)

    local manuallyMoved = true
    while ((not parent.EndOfFile) and (manuallyMoved or parent:MoveNext())) do
        local token   = parent.Tokens[parent.CurrentIndex] :: Token.Token
        manuallyMoved = false

        if (token.Type == TokenType.Decorator) then
            DecorateSlide(token, path)
        elseif (token.Type == TokenType.Slide) then
            local lastSegment = path.Segments[#path.Segments]
            ReadSegment(parent, token, lastSegment.Vertices[#lastSegment.Vertices], path)
            manuallyMoved = true
        elseif (token.Type == TokenType.Duration) then
            ReadDuration(parent.TimingChanges[#parent.TimingChanges], token, path)
        elseif (token.Type == TokenType.SlideJoiner) then
            parent:MoveNext()
            return path
        elseif (token.Type == TokenType.TimeStep) or (token.Type == TokenType.EachDivider) or (token.Type == TokenType.EndOfFile) or (token.Type == TokenType.Location) then
            return path
        elseif (token.Type == TokenType.None) then
            --// do nothing
        elseif (token.Type == TokenType.Tempo) or (token.Type == TokenType.Subdivision) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be global`)
        else
            assert(false, `unsupported syntax at {token.Line}@{token.Character}`)
        end
    end

    return path
end

return {
    Process           = Process,
    ReadSegment       = ReadSegment,
    DecorateSlide     = DecorateSlide,
    IdentifySlideType = IdentifySlideType,
    AssignVertices    = AssignVertices,
    ReadDuration      = ReadDuration,
}