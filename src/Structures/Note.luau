--!strict
local NoteStyles     = require("./NoteStyles")
local NoteAppearence = require("./NoteAppearence")
local NoteType       = require("./NoteType")
local NoteGroup      = require("./NoteGroup")
local SlideMorph     = require("./SlideMorph")
local Location       = require("./Location")
local SlidePath      = require("./SlidePath")

local Note = {}
Note.__index = Note

export type Note = setmetatable<{
    Location:         Location.Location,
    Styles:           {NoteStyles.NoteStyles},
    Appearence:       NoteAppearence.NoteAppearence,
    Type:             NoteType.NoteType,
    Length:           number?,
    SlideMorph:       SlideMorph.SlideMorph,
    SlidePaths:       {SlidePath.SlidePath},
    ParentCollection: any, --// NoteCollection
}, typeof(Note)>

function Note.IsEx(self: Note): boolean
    return (table.find(self.Styles, NoteStyles.Ex) ~= nil)
end

function Note.IsStar(self: Note): boolean
    return (self.Appearence == NoteAppearence.ForceStar) or (self.Appearence == NoteAppearence.ForceStarSpinning) or ((#self.SlidePaths > 0) and (self.Appearence ~= NoteAppearence.ForceNormal))
end

function Note.GetVisibleDuration(self: Note): number
    local baseValue = self.Length or 0
    if (#self.SlidePaths > 0) then
        baseValue = -math.huge
        for _, path in self.SlidePaths do
            baseValue = math.max(baseValue, path.Delay + path.Duration)
        end
    end
    return baseValue
end

--// equivalent to Note::WriteTo(StringWriter writer)
function Note.Get(self: Note): string
    local s = tostring(self.Location)

    --// Decorations
    if (table.find(self.Styles, NoteStyles.Ex)) then
        s ..= "x"
    end

    if (table.find(self.Styles, NoteStyles.Mine)) then
        s ..= "m"
    end

    --// Types
    if (self.Type == NoteType.ForceInvalidate) then
        s ..= if (self.SlideMorph == SlideMorph.FadeIn) then "?" else "!"
    end

    if     (self.Appearence == NoteAppearence.ForceNormal) then
        s ..= "@"
    elseif (self.Appearence == NoteAppearence.ForceStarSpinning) then
        s ..= "$$"
    elseif (self.Appearence == NoteAppearence.ForceStar) then
        s ..= "$"
    end

    if (self.Length) then
        s ..= string.format("h[#%.7f]", self.Length)
    end

    for _, path in self.SlidePaths do
        if (table.find(self.SlidePaths, path) ~= 1) then
            s ..= "*"
        end
        s ..= path:Get()
    end

    return s
end

return {
    new = function(parentCollection: any): Note
        return setmetatable({
            ParentCollection = parentCollection               :: any,
            SlidePaths       = {}                             :: {SlidePath.SlidePath},
            Location         = Location.new(0, NoteGroup.Tap) :: Location.Location,
            Styles           = {NoteStyles.None}              :: {NoteStyles.NoteStyles},
            Appearence       = NoteAppearence.Default         :: NoteAppearence.NoteAppearence,
            Type             = NoteType.Tap                   :: NoteType.NoteType,
            Length           = nil                            :: number?,
            SlideMorph       = SlideMorph.FadeIn              :: SlideMorph.SlideMorph,
        }, Note)
    end
}