--!strict
local NoteCollection = require("./NoteCollection")
local TimingChange   = require("../Internal/SyntacticAnalysis/TimingChange")

--// this certainly didn't need to be made a class (a simple table with type would do)
--// but lets just make it a class :+1:

local MaiChart = {}
MaiChart.__index = MaiChart

export type MaiChart = setmetatable<{
    FinishTiming:    number?,
    NoteCollections: {NoteCollection.NoteCollection},
    TimingChanges:   {TimingChange.TimingChange},
}, typeof(MaiChart)>

return {
    new = function(): MaiChart
        return setmetatable({
            FinishTiming    = nil :: number?,
            NoteCollections = {}  :: {NoteCollection.NoteCollection},
            TimingChanges   = {}  :: {TimingChange.TimingChange},
        }, MaiChart)
    end
}