--!strict
export type SlideMorph = "SlideMorph.FadeIn" | "SlideMorph.SuddenIn"
local SlideMorph = table.freeze({
    FadeIn   = "SlideMorph.FadeIn"   :: "SlideMorph.FadeIn",
    SuddenIn = "SlideMorph.SuddenIn" :: "SlideMorph.SuddenIn",
})
return SlideMorph