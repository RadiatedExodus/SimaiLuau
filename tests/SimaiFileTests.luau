local fs      = require("@lune/fs")
local frktest = require("@frktest/frktest")
local test    = frktest.test
local check   = frktest.assert.check
local req     = frktest.assert.require
local msg     = frktest.assert.msg

local MAIDATA_FILE_PATH = "./tests/Resources/SimaiFileTests/0.txt"
local MAIDATA_CONTENT   = fs.readFile(MAIDATA_FILE_PATH)

test.suite("SimaiFileTests", function()
    test.case("can read from string", function()
        local SimaiLuau = require("@SimaiLuau")
        local file      = SimaiLuau.SimaiFile.new(MAIDATA_CONTENT)
        local kvPairs   = file:ToKeyValuePairs()
        check.equal(kvPairs["title"],   "SimaiFileRead test case")
        check.equal(kvPairs["artist"],  "非英語文本");
        check.equal(kvPairs["first"],   "0");
        check.equal(kvPairs["lv_1"],    "12+");
        check.equal(kvPairs["inote_1"], "(170){4}A1/2,3h[4:1],E");
        return nil
    end)

    test.case("can convert to key-value pairs", function()
        local SimaiLuau = require("@SimaiLuau")
        local file      = SimaiLuau.SimaiFile.new(MAIDATA_CONTENT)
        local kvPairs   = file:ToKeyValuePairs()
        check.equal(kvPairs["title"],   "SimaiFileRead test case")
        check.equal(kvPairs["artist"],  "非英語文本");
        check.equal(kvPairs["first"],   "0");
        check.equal(kvPairs["lv_1"],    "12+");
        check.equal(kvPairs["inote_1"], "(170){4}A1/2,3h[4:1],E");
        return nil
    end)

    test.case("can read individual key-value pairs", function()
        local SimaiLuau = require("@SimaiLuau")
        local file      = SimaiLuau.SimaiFile.new(MAIDATA_CONTENT)
        check.equal(file:GetValue("inote_2"), "(170){1},{8}6h[8:1]/2,7,,3h[8:1]/7,2,,6h[8:1]/2,5,,E")
        return nil
    end)

    test.case("can read multi-line values", function()
        local SimaiLuau = require("@SimaiLuau")
        local file      = SimaiLuau.SimaiFile.new(MAIDATA_CONTENT)
        local expected  = [[(170){16}7/2-6[8:1],,1-5[8:1],8,2,,1,,
              {8}2,18,7,16,2/7h[4:1],1,
              3,{16}3,4,{8}2h[8:1]/5h[8:1],,18,,
              {16}2/7-3[8:1],,8-4[8:1],1,7,,8,,
              {8}7,81,2,83,7/2h[4:1],8,
              6,{16}6,5,{8}7h[8:1]/4h[8:1],,7h[16:3]/1,,]]
        check.equal(file:GetValue("inote_3"), expected)
        return nil
    end)

    return nil
end)

return true