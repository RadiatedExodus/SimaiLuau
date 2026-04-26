local fs        = require("@lune/fs")
local frktest   = require("@frktest/frktest")
local SimaiLuau = require("@SimaiLuau")
local Location  = require("@SimaiLuau/Structures/Location")
local NoteGroup = require("@SimaiLuau/Structures/NoteGroup")
local test      = frktest.test
local check     = frktest.assert.check
local req       = frktest.assert.require
local msg       = frktest.assert.msg

test.suite("SimaiChartTests", function()
    test.case("can read empty charts", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadEmptyChart.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 0)
        return nil
    end)

    test.case("can read singular locations", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadSingularLocation.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 1)
        check.equal(#chart.NoteCollections[1].Collection, 1)
        check.equal(chart.NoteCollections[1].Collection[1].Location, Location.new(0, NoteGroup.Tap))
        return nil
    end)

    test.case("can read locations with separators", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadLocationsWithSeparators.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 1)
        check.equal(#chart.NoteCollections[1].Collection, 8)
        check.equal(chart.NoteCollections[1].Collection[1].Location, Location.new(0, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[2].Location, Location.new(1, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[3].Location, Location.new(2, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[4].Location, Location.new(3, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[5].Location, Location.new(4, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[6].Location, Location.new(5, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[7].Location, Location.new(6, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[8].Location, Location.new(7, NoteGroup.Tap))
        return nil
    end)

    test.case("can read locations without separators", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadLocationsWithoutSeparators.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 1)
        check.equal(#chart.NoteCollections[1].Collection, 8)
        check.equal(chart.NoteCollections[1].Collection[1].Location, Location.new(0, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[2].Location, Location.new(1, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[3].Location, Location.new(2, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[4].Location, Location.new(3, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[5].Location, Location.new(4, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[6].Location, Location.new(5, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[7].Location, Location.new(6, NoteGroup.Tap))
        check.equal(chart.NoteCollections[1].Collection[8].Location, Location.new(7, NoteGroup.Tap))
        return nil
    end)

    test.case("can read tempo with default subdivisions", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadTempoWithDefaultSubdivisions.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 2)
        check.equal(chart.NoteCollections[2].Time, 1)
        return nil
    end)

    test.case("can read tempo changes with default subdivisions", function()
        local maidata   = fs.readFile("./tests/Resources/SimaiChartTests/CanReadTempoChangesWithDefaultSubdivisions.txt")
        local file      = SimaiLuau.SimaiFile.new(maidata)
        local chart     = SimaiLuau.Deserialize(file:GetValue("inote_1") :: string)
        check.equal(#chart.NoteCollections, 3)
        check.equal(chart.NoteCollections[2].Time, 1)
        check.equal(chart.NoteCollections[3].Time, 1.5)
        return nil
    end)

    test.case("can serialize", function()
        local maidata    = fs.readFile("./tests/Resources/SimaiFileTests/0.txt")
        local file       = SimaiLuau.SimaiFile.new(maidata)
        local chart      = SimaiLuau.Deserialize(file:GetValue("inote_3") :: string)
        local serialized = SimaiLuau.Serialize(chart)
        msg(serialized)
        check.not_equal(serialized, "")
        return nil
    end)

    return nil
end)

return true