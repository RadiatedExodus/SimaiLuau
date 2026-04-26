--!strict
local TimingChange      = require("./TimingChange")
local NoteReader        = require("./States/NoteReader")
local SubdivisionReader = require("./States/SubdivisionReader")
local TempoReader       = require("./States/TempoReader")
local Extensions        = require("../Extensions")
local Token             = require("../LexicalAnalysis/Token")
local TokenType         = require("../LexicalAnalysis/TokenType")
local MaiChart          = require("../../Structures/MaiChart")
local NoteCollection    = require("../../Structures/NoteCollection")
local EachStyle         = require("../../Structures/EachStyle")

--// NOTE: DetermineRingType and TryReadLocation moved to Extensions.luau

local Deserializer = {}
Deserializer.__index = Deserializer

export type Deserializer = setmetatable<{
    __Chart:               MaiChart.MaiChart,
    Tokens:                {Token.Token},
    CurrentIndex:          number,
    TimingChanges:         {TimingChange.TimingChange},
    __MaxFinishTime:       number,
    CurrentTime:           number,
    CurrentNoteCollection: NoteCollection.NoteCollection?,
    EndOfFile:             boolean,
}, typeof(Deserializer)>

function Deserializer.GetChart(self: Deserializer): MaiChart.MaiChart
    local noteCollections = {} :: {NoteCollection.NoteCollection}

    local manuallyMoved = false
    while ((not self.EndOfFile) and (manuallyMoved or self:MoveNext())) do
        local token   = self.Tokens[self.CurrentIndex] :: Token.Token
        manuallyMoved = true
        if (token.Type == TokenType.Tempo) then
            TempoReader.Process(self, token)
        elseif (token.Type == TokenType.Subdivision) then
            SubdivisionReader.Process(self, token)
        elseif (token.Type == TokenType.Location) then
            self.CurrentNoteCollection = self.CurrentNoteCollection or NoteCollection.new(self.CurrentTime)
            if (string.sub(token.Lexeme, 1, 1) == "0") then
                if (self.CurrentNoteCollection.EachStyle ~= EachStyle.ForceBroken) then
                    self.CurrentNoteCollection.EachStyle = EachStyle.ForceEach
                end
            else
                local note = NoteReader.Process(self, token)
                self.CurrentNoteCollection.AddNote(note)
                manuallyMoved = true
                self.__MaxFinishTime = math.max(self.__MaxFinishTime, self.CurrentNoteCollection.Time + note:GetVisibleDuration())
            end
        elseif (token.Type == TokenType.TimeStep) then
            if (self.CurrentNoteCollection ~= nil) then
                table.insert(noteCollections, self.CurrentNoteCollection)
                self.CurrentNoteCollection = nil
            end
            self.CurrentTime += self.TimingChanges[#self.TimingChanges]:SecondsPerBeat()
        elseif (token.Type == TokenType.EachDivider) then
            local firstChar = string.sub(token.Lexeme, 1, 1)
            if (firstChar == "/") then
                --// do nothing
            elseif (firstChar == "`") then
                if (self.CurrentNoteCollection ~= nil) then
                    self.CurrentNoteCollection.EachStyle = EachStyle.ForceBroken
                end
            end
        elseif (token.Type == TokenType.Decorator) or (token.Type == TokenType.Slide) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be note`)
        elseif (token.Type == TokenType.Duration) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be note or slide`)
        elseif (token.Type == TokenType.SlideJoiner) then
            assert(false, `scope mismatch at {token.Line}@{token.Character}, correct scope should be slide`)
        elseif (token.Type == TokenType.EndOfFile) then
            self.__Chart.FinishTiming = self.CurrentTime
        elseif (token.Type == TokenType.None) then
            --// do nothing
        else
            assert(false, `unsupported syntax at {token.Line}@{token.Character}`)
        end
    end

    self.__Chart.FinishTiming = self.__Chart.FinishTiming or self.__MaxFinishTime

    if (self.CurrentNoteCollection ~= nil) then
        table.insert(noteCollections, self.CurrentNoteCollection)
        self.CurrentNoteCollection = nil
    end

    self.__Chart.NoteCollections = noteCollections
    self.__Chart.TimingChanges   = self.TimingChanges

    return self.__Chart
end

function Deserializer.MoveNext(self: Deserializer): boolean
    if (self.EndOfFile) then return false end
    self.CurrentIndex += 1

    local token = self.Tokens[self.CurrentIndex] :: Token.Token
    if (token == nil) then
        self.EndOfFile = true
        return false
    end

    if (token.Type == TokenType.EndOfFile) then
        self.EndOfFile = true
    end

    return true
end

return {
    new = function(sequence: {Token.Token}): Deserializer
        return setmetatable({
            __Chart               = MaiChart.new(),
            Tokens                = sequence,
            CurrentIndex          = 0,
            TimingChanges         = {TimingChange.new()},
            __MaxFinishTime       = 0,
            CurrentTime           = 0,
            CurrentNoteCollection = nil :: NoteCollection.NoteCollection?,
            EndOfFile             = false
        }, Deserializer)
    end,
    DetermineRingType = Extensions.DetermineRingType,
    TryReadLocation   = Extensions.TryReadLocation,
}