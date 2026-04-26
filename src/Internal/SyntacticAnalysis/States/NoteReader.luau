--!strict
local SlideReader    = require("./SlideReader")
local TimingChange   = require("../TimingChange")
local Extensions     = require("../../Extensions")
local Token          = require("../../LexicalAnalysis/Token")
local TokenType      = require("../../LexicalAnalysis/TokenType")
local Note           = require("../../../Structures/Note")
local NoteType       = require("../../../Structures/NoteType")
local NoteAppearence = require("../../../Structures/NoteAppearence")
local NoteStyles     = require("../../../Structures/NoteStyles")
local SlideMorph     = require("../../../Structures/SlideMorph")
local NoteGroup      = require("../../../Structures/NoteGroup")

local function DecorateNote(token: Token.Token, note: Note.Note)
    local firstChar = string.sub(token.Lexeme, 1, 1)
    if     (firstChar == "f") then
        table.insert(note.Styles, NoteStyles.Fireworks)
    elseif (firstChar == "b") and (note.Type ~= NoteType.ForceInvalidate) then
        note.Type = NoteType.Break
    elseif (firstChar == "x") then
        table.insert(note.Styles, NoteStyles.Ex)
    elseif (firstChar == "m") then
        table.insert(note.Styles, NoteStyles.Mine)
    elseif (firstChar == "h") then
        if (note.Type ~= NoteType.Break) and (note.Type ~= NoteType.ForceInvalidate) then
            note.Type = NoteType.Hold
        end
        note.Length = note.Length or 0
    elseif (firstChar == "?") then
        note.Type       = NoteType.ForceInvalidate
        note.SlideMorph = SlideMorph.FadeIn
    elseif (firstChar == "!") then
        note.Type       = NoteType.ForceInvalidate
        note.SlideMorph = SlideMorph.SuddenIn
    elseif (firstChar == "@") then
        note.Appearence = NoteAppearence.ForceNormal
    elseif (firstChar == "$") then
        note.Appearence = if (note.Appearence == NoteAppearence.ForceStar) then NoteAppearence.ForceStarSpinning else NoteAppearence.ForceStar
    end
    return
end

local function ReadDuration(timing: TimingChange.TimingChange, token: Token.Token, note: Note.Note)
    if (note.Type ~= NoteType.Break) then
        note.Type = NoteType.Hold
    end

    local indexOfHash = string.find(token.Lexeme, "#") :: number
    if (indexOfHash == 1) then
        local explicitValue = tonumber(string.sub(token.Lexeme, 2))
        assert(explicitValue, `unexpected character at {token.Line}@{token.Character + 1}, expected 0~9, or "."`)
        note.Length = explicitValue
        return
    end

    if (indexOfHash ~= nil) then
        local tempo = tonumber(string.sub(token.Lexeme, 1, indexOfHash - 1))
        assert(tempo, `unexpected character at {token.Line}@{token.Character + 1}, expected 0~9, or "."`)
        timing.Tempo = tempo
    end

    local nominatorStart   = if indexOfHash ~= nil then indexOfHash + 1 else 1
    local indexOfSeparator = string.find(token.Lexeme, ":")
    assert(indexOfSeparator, `unexpected character at {token.Line}@{token.Character}, expected ":"`)

    local nominator = tonumber(string.sub(token.Lexeme, nominatorStart, indexOfSeparator - 1))
    assert(nominator, `unexpected character at {token.Line}@{token.Character}, expected 0~9, or "."`)

    local denominator = tonumber(string.sub(token.Lexeme, indexOfSeparator + 1))
    assert(denominator, `unexpected character at {token.Line}@{token.Character + indexOfSeparator}, expected 0~9, or "."`)

    note.Length = timing:SecondsPerBar() / (nominator / 4) * denominator
    return
end

local function Process(parent: any, identityToken: Token.Token): Note.Note
    local readLoc, noteLocation = Extensions.TryReadLocation(identityToken)
    assert(readLoc, `invalid syntax at {identityToken.Line}@{identityToken.Character}`)

    local currentNote    = Note.new(parent.CurrentNoteCollection)
    currentNote.Location = noteLocation

    local overrideTiming = TimingChange.new()
    overrideTiming.Tempo = parent.TimingChanges[#parent.TimingChanges].Tempo

    if (noteLocation.Group ~= NoteGroup.Tap) then
        currentNote.Type = NoteType.Touch
    end

    local manuallyMoved = false
    while ((not parent.EndOfFile) and (manuallyMoved or parent:MoveNext())) do
        local token   = parent.Tokens[parent.CurrentIndex] :: Token.Token
        manuallyMoved = false

        if     (token.Type == TokenType.Decorator) then
            DecorateNote(token, currentNote)
        elseif (token.Type == TokenType.Slide) then
            if (currentNote.Type == NoteType.Hold) then
                currentNote.Length = overrideTiming:SecondsPerBeat()
            end
            local slide = SlideReader.Process(parent, currentNote, token, overrideTiming)
            manuallyMoved = true
            table.insert(currentNote.SlidePaths, slide)
        elseif (token.Type == TokenType.Duration) then
            ReadDuration(parent.TimingChanges[#parent.TimingChanges], token, currentNote)
        elseif (token.Type == TokenType.TimeStep) or (token.Type == TokenType.EachDivider) or (token.Type == TokenType.EndOfFile) or (token.Type == TokenType.Location) then
            return currentNote
        elseif (token.Type == TokenType.None) then
            --// do nothing
        elseif (token.Type == TokenType.Tempo) or (token.Type == TokenType.Subdivision) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be global`)
        elseif (token.Type == TokenType.SlideJoiner) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be slide`)
        else
            assert(false, `unsupported syntax at {token.Line}@{token.Character}`)
        end
    end

    return currentNote
end

return {
    Process      = Process,
    DecorateNote = DecorateNote,
    ReadDuration = ReadDuration,
}