--!strict
local EachStyle = require("./EachStyle")
local Note      = require("./Note")

local NoteCollection = {}
NoteCollection.__index = NoteCollection

export type NoteCollection = setmetatable<{
    Collection: {Note.Note},
    EachStyle:  EachStyle.EachStyle,
    Time:       number,
}, typeof(NoteCollection)>

function NoteCollection.AddNote(self: NoteCollection, n: Note.Note)
    n.ParentCollection = self
    table.insert(self.Collection, n)
    return
end

return {
    new = function(time: number): NoteCollection
        return setmetatable({
            Collection = {}                :: {Note.Note},
            EachStyle  = EachStyle.Default :: EachStyle.EachStyle,
            Time       = time              :: number,
        }, NoteCollection)
    end
}