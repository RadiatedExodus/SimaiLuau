--!strict
local MaiChart     = require("./Structures/MaiChart")
local Tokenizer    = require("./Internal/LexicalAnalysis/Tokenizer")
local Serializer   = require("./Internal/SyntacticAnalysis/Serializer")
local Deserializer = require("./Internal/SyntacticAnalysis/Deserializer")

local function Deserialize(value: string): MaiChart.MaiChart
    local tokens = Tokenizer.new(value):GetTokens()
    local chart  = Deserializer.new(tokens):GetChart()
    return chart
end

local function Serialize(chart: MaiChart.MaiChart): string
    local serializer = Serializer.new()
    return serializer:Serialize(chart)
end

return {
    Deserialize = Deserialize,
    Serialize   = Serialize,
}
