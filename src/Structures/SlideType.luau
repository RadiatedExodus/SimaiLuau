--!strict
export type SlideType = "SlideType.StraightLine" | "SlideType.RingCw" | "SlideType.RingCcw" | "SlideType.Fold" | "SlideType.CurveCw" | "SlideType.CurveCcw" | "SlideType.ZigZagS" | "SlideType.ZigZagZ" | "SlideType.EdgeFold" | "SlideType.EdgeCurveCw" | "SlideType.EdgeCurveCcw" | "SlideType.Fan"
local SlideType = table.freeze({
    StraightLine = "SlideType.StraightLine" :: "SlideType.StraightLine",
    RingCw       = "SlideType.RingCw"       :: "SlideType.RingCw",
    RingCcw      = "SlideType.RingCcw"      :: "SlideType.RingCcw",
    Fold         = "SlideType.Fold"         :: "SlideType.Fold",
    CurveCw      = "SlideType.CurveCw"      :: "SlideType.CurveCw",
    CurveCcw     = "SlideType.CurveCcw"     :: "SlideType.CurveCcw",
    ZigZagS      = "SlideType.ZigZagS"      :: "SlideType.ZigZagS",
    ZigZagZ      = "SlideType.ZigZagZ"      :: "SlideType.ZigZagZ",
    EdgeFold     = "SlideType.EdgeFold"     :: "SlideType.EdgeFold",
    EdgeCurveCw  = "SlideType.EdgeCurveCw"  :: "SlideType.EdgeCurveCw",
    EdgeCurveCcw = "SlideType.EdgeCurveCcw" :: "SlideType.EdgeCurveCcw",
    Fan          = "SlideType.Fan"          :: "SlideType.Fan",
})
return SlideType