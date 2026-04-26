--!strict
export type NoteStyles = "NoteStyles.None" | "NoteStyles.Ex" | "NoteStyles.Fireworks" | "NoteStyles.Mine"
local NoteStyles = table.freeze({
    None      = "NoteStyles.None"      :: "NoteStyles.None",
    Ex        = "NoteStyles.Ex"        :: "NoteStyles.Ex",
    Fireworks = "NoteStyles.Fireworks" :: "NoteStyles.Fireworks",
    Mine      = "NoteStyles.Mine"      :: "NoteStyles.Mine",
})
return NoteStyles