--!strict
local TimingChange = require("../TimingChange")
local Token        = require("../../LexicalAnalysis/Token")

--// source: chatgpt
local EPSILON = 1e-6

local function CloneTimingChange(tc: TimingChange.TimingChange): TimingChange.TimingChange
    local new        = TimingChange.new()
    new.Subdivisions = tc.Subdivisions
    new.Tempo        = tc.Tempo
    new.Time         = tc.Time
    return new
end

local function Process(parent: any, token: Token.Token)
    if (string.sub(token.Lexeme, 1, 1)) then
        local explicitTempo = tonumber(string.sub(token.Lexeme, 2))
        assert(explicitTempo, `unexpected character at {token.Line}@{token.Character}, expected 0~9 or "."`)

        local newTimingChange = CloneTimingChange(parent.TimingChanges[#parent.TimingChanges])
        newTimingChange:SetSeconds(explicitTempo)
        newTimingChange.Time = parent.CurrentTime

        if (math.abs(parent.TimingChanges[#parent.TimingChanges].Time - parent.CurrentTime) <= EPSILON) then
            local lastIndex = table.find(parent.TimingChanges, parent.TimingChanges[#parent.TimingChanges])
            table.remove(parent.TimingChanges, lastIndex)
        end

        table.insert(parent.TimingChanges, newTimingChange)
        return
    end

    local subdivision = tonumber(token.Lexeme)
    assert(subdivision, `unexpected character at {token.Line}@{token.Character}, expected 0~9 or "."`)

    local newTimingChange        = CloneTimingChange(parent.TimingChanges[#parent.TimingChanges])
    newTimingChange.Subdivisions = subdivision
    newTimingChange.Time         = parent.CurrentTime

    if (math.abs(parent.TimingChanges[#parent.TimingChanges].Time - parent.CurrentTime) <= EPSILON) then
        local lastIndex = table.find(parent.TimingChanges, parent.TimingChanges[#parent.TimingChanges])
        table.remove(parent.TimingChanges, lastIndex)
    end

    table.insert(parent.TimingChanges, newTimingChange)
    return
end

return { Process = Process }