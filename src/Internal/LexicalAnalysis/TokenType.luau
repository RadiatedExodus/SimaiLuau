--!strict
export type TokenType = "TokenType.None" | "TokenType.Tempo" | "TokenType.Subdivision" | "TokenType.Location" | "TokenType.Decorator" | "TokenType.Slide" | "TokenType.Duration" | "TokenType.SlideJoiner" | "TokenType.TimeStep" | "TokenType.EachDivider" | "TokenType.EndOfFile"
local TokenType = table.freeze({
    None        = "TokenType.None"        :: "TokenType.None",
    Tempo       = "TokenType.Tempo"       :: "TokenType.Tempo",
    Subdivision = "TokenType.Subdivision" :: "TokenType.Subdivision",
    Location    = "TokenType.Location"    :: "TokenType.Location",
    Decorator   = "TokenType.Decorator"   :: "TokenType.Decorator",
    Slide       = "TokenType.Slide"       :: "TokenType.Slide",
    Duration    = "TokenType.Duration"    :: "TokenType.Duration",
    SlideJoiner = "TokenType.SlideJoiner" :: "TokenType.SlideJoiner",
    TimeStep    = "TokenType.TimeStep"    :: "TokenType.TimeStep",
    EachDivider = "TokenType.EachDivider" :: "TokenType.EachDivider",
    EndOfFile   = "TokenType.EndOfFile"   :: "TokenType.EndOfFile",
})
return TokenType