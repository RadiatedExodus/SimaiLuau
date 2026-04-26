--!strict
local NoteGroup    = require("./NoteGroup")
local NoteType     = require("./NoteType")
local Location     = require("./Location")
local SlideSegment = require("./SlideSegment")

local SlidePath = {}
SlidePath.__index = SlidePath

export type SlidePath = setmetatable<{
    StartLocation: Location.Location,
    Segments:      {SlideSegment.SlideSegment},
    Delay:         number,
    Duration:      number,
    Type:          NoteType.NoteType,
}, typeof(SlidePath)>

--// equivalent to SlidePath::WriteTo(StringWriter writer)
function SlidePath.Get(self: SlidePath): string
    local s = ""

    for _, v in self.Segments do
        s ..= v:Get(self.StartLocation)
    end

    if (self.Type == NoteType.Break) then
        s ..= "b"
    end

    s ..= string.format("[%.7f##%.7f]", self.Delay, self.Duration)

    return s
end

return {
    new = function(segments: {SlideSegment.SlideSegment}): SlidePath
        return setmetatable({
            Segments      = segments,
            StartLocation = Location.new(0, NoteGroup.Tap) :: Location.Location,
            Delay         = 0,
            Duration      = 0,
            Type          = NoteType.Slide :: NoteType.NoteType
        }, SlidePath)
    end
}