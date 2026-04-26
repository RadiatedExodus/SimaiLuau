--!strict
export type NoteGroup = "NoteGroup.Tap" | "NoteGroup.ASensor" | "NoteGroup.BSensor" | "NoteGroup.CSensor" | "NoteGroup.DSensor" | "NoteGroup.ESensor"
local NoteGroup = table.freeze({
    Tap     = "NoteGroup.Tap"     :: "NoteGroup.Tap",
    ASensor = "NoteGroup.ASensor" :: "NoteGroup.ASensor",
    BSensor = "NoteGroup.BSensor" :: "NoteGroup.BSensor",
    CSensor = "NoteGroup.CSensor" :: "NoteGroup.CSensor",
    DSensor = "NoteGroup.DSensor" :: "NoteGroup.DSensor",
    ESensor = "NoteGroup.ESensor" :: "NoteGroup.ESensor",
})
return NoteGroup