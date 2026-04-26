--!strict
local TimingChange = {}
TimingChange.__index = TimingChange

export type TimingChange = setmetatable<{
    Time:         number,
    Tempo:        number,
    Subdivisions: number,
}, typeof(TimingChange)>

function TimingChange.SecondsPerBar(self: TimingChange): number
    return if (self.Tempo == 0) then 0 else 60 / self.Tempo
end

function TimingChange.SecondsPerBeat(self: TimingChange): number
    return self:SecondsPerBar() / ((if (self.Subdivisions == 0) then 4 else self.Subdivisions) / 4)
end

function TimingChange.SetSeconds(self: TimingChange, value: number)
    self.Tempo        = 60 / value
    self.Subdivisions = 4
    return
end

return {
    new = function(): TimingChange
        return setmetatable({
            Time         = 0,
            Tempo        = 0,
            Subdivisions = 0,
        }, TimingChange)
    end
}