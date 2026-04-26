--!strict
export type EachStyle = "EachStyle.Default" | "EachStyle.ForceBroken" | "EachStyle.ForceEach"
local EachStyle = table.freeze({
    Default     = "EachStyle.Default"     :: "EachStyle.Default",
    ForceBroken = "EachStyle.ForceBroken" :: "EachStyle.ForceBroken",
    ForceEach   = "EachStyle.ForceEach"   :: "EachStyle.ForceEach",
})
return EachStyle