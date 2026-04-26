--!strict
local NoteGroup = require("./NoteGroup")

local Location = {}
Location.__index     = Location

export type Location = setmetatable<{
    Index: number,
    Group: NoteGroup.NoteGroup,
}, typeof(Location)>

function Location.__tostring(self: Location): string
    if (self.Group == NoteGroup.Tap) then
        return tostring(self.Index)
    end

    if (self.Group == NoteGroup.CSensor) then
        return "C"
    end

    return `{self.Group}{self.Index}`
end

function Location.__eq(self: Location, other: Location): boolean
    return (typeof(other) == "table") and (getmetatable(other) == Location) and (self.Index == other.Index) and (self.Group == other.Group)
end

return {
    new = function(index: number, group: NoteGroup.NoteGroup): Location
        return setmetatable({
            Index = index,
            Group = group,
        }, Location)
    end 
}