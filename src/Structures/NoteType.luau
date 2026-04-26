--!strict
export type NoteType = "NoteType.Tap" | "NoteType.Touch" | "NoteType.Hold" | "NoteType.Slide" | "NoteType.Break" | "NoteType.ForceInvalidate"
local NoteType = table.freeze({
    Tap             = "NoteType.Tap"             :: "NoteType.Tap",
    Touch           = "NoteType.Touch"           :: "NoteType.Touch",
    Hold            = "NoteType.Hold"            :: "NoteType.Hold",
    Slide           = "NoteType.Slide"           :: "NoteType.Slide",
    Break           = "NoteType.Break"           :: "NoteType.Break",
    ForceInvalidate = "NoteType.ForceInvalidate" :: "NoteType.ForceInvalidate",
})
return NoteType