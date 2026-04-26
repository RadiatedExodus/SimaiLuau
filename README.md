# SimaiLuau
SimaiLuau is an interpreter and serializer for [simai](https://w.atwiki.jp/simai/), a custom chart format for the arcade rythm game [maimai](https://maimai.sega.jp/), written in [Luau](https://luau.org/) and based off [SimaiSharp](https://github.com/reflektone-games/SimaiSharp).

# Getting Started
To use SimaiLuau in your own project, you will need to add the SimaiLuau library to your project and then use the following method to deserialize a chart:
```luau
--// Assume this variable to be storing the simai file contents taken from somewhere (e.g. user input or file)
local simaiFileContents = ""

--// Use SimaiFile to read it
local simaiFile = SimaiFile.new(simaiFileContents)

--// Specify a key that you want to read, without the "&"
local chartKey = "inote_5"

--// Get the corresponding value as a string
local rawChart = simaiFile:GetValue(chartKey)

--// Deserialize the chart
local chart = SimaiConvert.Deserialize(rawChart)
```