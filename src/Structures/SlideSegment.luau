--!strict
local Location  = require("./Location")
local SlideType = require("./SlideType")

local SlideSegment = {}
SlideSegment.__index = SlideSegment

export type SlideSegment = setmetatable<{
    Vertices:  {Location.Location},
    SlideType: SlideType.SlideType
}, typeof(SlideSegment)>

--// equivalent of SlideSegment::WriteTo(StringWriter writer, Location startLocation)
function SlideSegment.Get(self: SlideSegment, startLocation: Location.Location): string
    if     (self.SlideType == SlideType.StraightLine) then
        return `-{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.RingCw) then
        return if ((startLocation.Index + 1) % 8 >= 4) then `<{self.Vertices[1]}` else `>{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.RingCcw) then
        return if ((startLocation.Index + 1) % 8 >= 4) then `<{self.Vertices[1]}` else `>{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.Fold) then
        return `v{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.CurveCw) then
        return `q{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.CurveCcw) then
        return `pp{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.ZigZagS) then
        return `s{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.ZigZagZ) then
        return `z{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.EdgeFold) then
        return `V{self.Vertices[1]}{self.Vertices[2]}`
    elseif (self.SlideType == SlideType.EdgeCurveCw) then
        return `qq{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.EdgeCurveCcw) then
        return `pp{self.Vertices[1]}`
    elseif (self.SlideType == SlideType.Fan) then
        return `w{self.Vertices[1]}`
    else
        assert(false, "out of range")
    end
end

return {
    new = function(vertices: {Location.Location}?): SlideSegment
        return setmetatable({
            Vertices  = if (vertices) then vertices else {},
            SlideType = SlideType.StraightLine :: SlideType.SlideType
        }, SlideSegment)
    end
}