--!strict
local SimaiConvert = require("./src/SimaiConvert")
local SimaiFile    = require("./src/SimaiFile")

return {
    SimaiFile   = SimaiFile,
    Deserialize = SimaiConvert.Deserialize,
    Serialize   = SimaiConvert.Serialize,
}