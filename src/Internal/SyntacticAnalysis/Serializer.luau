--!strict
local MaiChart     = require("../../Structures/MaiChart")
local EachStyle    = require("../../Structures/EachStyle")
local NoteCollection = require("../../structures/NoteCollection")

--// source: chatgpt
local EPSILON = 1e-6

local Serializer = {}
Serializer.__index = Serializer

export type Serializer = setmetatable<{
    __CurrentTimingChange:   number,
    __CurrentNoteCollection: number,
    __CurrentTime:           number,
}, typeof(Serializer)>

local function SerializeNoteCollection(notes: NoteCollection.NoteCollection): string
    local separator = if (notes.EachStyle == EachStyle.ForceBroken) then '`' else '/'
    local s = ""

    if (notes.EachStyle == EachStyle.ForceEach) then
        s ..= "0/"
    end

    for i = 1, #notes.Collection do
        s ..= notes.Collection[i]:Get()
        if (i ~= #notes.Collection) then
            s ..= separator
        end
    end

    return s
end

function Serializer.Serialize(self: Serializer, chart: MaiChart.MaiChart): string
    local s = ""
    s ..= `({chart.TimingChanges[self.__CurrentTimingChange].Tempo})`
	s ..= `\{\{{chart.TimingChanges[self.__CurrentTimingChange].Subdivisions}}}`

    while (self.__CurrentTime <= (chart.FinishTiming or 0)) do
        if (self.__CurrentTimingChange < (#chart.TimingChanges - 1)) and (math.abs(chart.TimingChanges[self.__CurrentTimingChange + 1].Time - self.__CurrentTime) < EPSILON) then
            self.__CurrentTimingChange += 1

            if (math.abs(chart.TimingChanges[self.__CurrentTimingChange].Tempo - chart.TimingChanges[self.__CurrentTimingChange - 1].Tempo) > EPSILON) then
                s ..= `({chart.TimingChanges[self.__CurrentTimingChange].Tempo})`
            end

            if (math.abs(chart.TimingChanges[self.__CurrentTimingChange].Subdivisions - chart.TimingChanges[self.__CurrentTimingChange - 1].Subdivisions) > EPSILON) then
                s ..= `\{\{{chart.TimingChanges[self.__CurrentTimingChange].Subdivisions}}}`
            end
        end

        if (self.__CurrentNoteCollection < #chart.NoteCollections) and (math.abs(chart.NoteCollections[self.__CurrentNoteCollection].Time - self.__CurrentTime) <= EPSILON) then
            SerializeNoteCollection(chart.NoteCollections[self.__CurrentNoteCollection])
            self.__CurrentNoteCollection += 1
        end

        local timingChange = chart.TimingChanges[self.__CurrentTimingChange]
        self.__CurrentTime += timingChange:SecondsPerBeat()
        s ..= ","
    end
    s ..= "E"

    return s
end

return {
    new = function(): Serializer
        return setmetatable({
            __CurrentTimingChange   = 0,
            __CurrentNoteCollection = 0,
            __CurrentTime           = 0,
        }, Serializer)
    end,
    SerializeNoteCollection = SerializeNoteCollection,
}