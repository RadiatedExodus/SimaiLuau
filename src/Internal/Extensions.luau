--!strict
local SlideType    = require("../Structures/SlideType")
local Location     = require("../Structures/Location")
local NoteGroup    = require("../Structures/NoteGroup")
local Token        = require("./LexicalAnalysis/Token")
local TimingChange = require("./SyntacticAnalysis/TimingChange")

local SENSORCHAR_TO_NOTEGROUP = {
    A = NoteGroup.ASensor,
    B = NoteGroup.BSensor,
    C = NoteGroup.CSensor,
    D = NoteGroup.DSensor,
    E = NoteGroup.ESensor,
} :: {[string]: NoteGroup.NoteGroup}

local function RemoveLineEndings(value: string): string
    local new = value:gsub("\r\n", ""):gsub("\n", ""):gsub("\r", ""):gsub(utf8.char(0x2028), ""):gsub(utf8.char(0x2029), "")
    return new
end

--// originally part of Deserializer
local function DetermineRingType(startLocation: Location.Location, endLocation: Location.Location, direction: number?): SlideType.SlideType
    if     (direction == 1) then
        return if ((startLocation.Index + 1) % 8 >= 4) then SlideType.RingCcw else SlideType.RingCw
    elseif (direction == -1) then
        return if ((startLocation.Index + 1) % 8 >= 4) then SlideType.RingCw else SlideType.RingCcw
    else
        local difference = endLocation.Index - startLocation.Index
        local rotation   = if (difference >= 0) then 
            (if (difference > 4) then -1 else 1) else
            (if (difference < -4) then 1 else -1)
        return if (rotation > 0) then SlideType.RingCw else SlideType.RingCcw
    end
end

--// originally part of Deserializer
local function TryReadLocation(token: Token.Token): (boolean, Location.Location)
    local firstChar  = string.sub(token.Lexeme, 1, 1)
    local isSensor   = (firstChar >= "A") and (firstChar <= "E")
    local indexRange = if (isSensor) then string.sub(token.Lexeme, 2) else token.Lexeme
    local group      = NoteGroup.Tap :: NoteGroup.NoteGroup

    if (isSensor) then
        group = SENSORCHAR_TO_NOTEGROUP[firstChar]
        if (group == NoteGroup.CSensor) then
            return true, Location.new(1, group)
        end
    end

    local indexInGroup = tonumber(indexRange)
    if (not indexInGroup) then
        return false, Location.new(1, NoteGroup.Tap)
    end

    return true, Location.new(indexInGroup, group)
end

local function CloneTimingChange(tc: TimingChange.TimingChange): TimingChange.TimingChange
    local new        = TimingChange.new()
    new.Subdivisions = tc.Subdivisions
    new.Tempo        = tc.Tempo
    new.Time         = tc.Time
    return new
end

local function StringLastIndexOf(text: string, pattern: string): number?
	local lastFound   = nil :: number?
	local searchStart = 1
	while (true) do
		local found = string.find(text, pattern, searchStart)
		if (found == nil) then break end

		lastFound   = found
		searchStart = found + 1
	end
	return lastFound
end

return {
    RemoveLineEndings = RemoveLineEndings,
    DetermineRingType = DetermineRingType,
    TryReadLocation   = TryReadLocation,
    CloneTimingChange = CloneTimingChange,
    StringLastIndexOf = StringLastIndexOf,
}