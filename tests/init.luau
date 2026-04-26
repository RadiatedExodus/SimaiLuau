--!strict
local frktest         = require("@frktest/frktest")
local consoleReporter = require("@frktest/reporters/console_reporter")
local process         = require("@lune/process")

require("./tests/SimaiFileTests")
require("./tests/SimaiChartTests")

consoleReporter.init()
local testOk = frktest.run()
if (not testOk) then
    process.exit(1)
end
