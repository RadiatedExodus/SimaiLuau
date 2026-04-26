--!strict
export type NoteAppearence = "NoteAppearence.Default" | "NoteAppearence.ForceNormal" | "NoteAppearence.ForceStar" | "NoteAppearence.ForceStarSpinning"
local NoteAppearence = table.freeze({
    Default           = "NoteAppearence.Default"           :: "NoteAppearence.Default",
    ForceNormal       = "NoteAppearence.ForceNormal"       :: "NoteAppearence.ForceNormal",
    ForceStar         = "NoteAppearence.ForceStar"         :: "NoteAppearence.ForceStar",
    ForceStarSpinning = "NoteAppearence.ForceStarSpinning" :: "NoteAppearence.ForceStarSpinning",
})
return NoteAppearence