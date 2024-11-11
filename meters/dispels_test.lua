local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/dispels.lua")("test", nekometer)

TestDispels = {}

local meter = nekometer.meters.dispels

function TestDispels:test_meter()
    local events = {
        {
            IsDispel = function() return true end,
            GetSource = function() return { id = "id1", name = "unit1" } end,
        },
        {
            IsDispel = function() return true end,
            GetSource = function() return { id = "id2", name = "unit2" } end,
        },
        {
            IsDispel = function() return false end,
        },
    }

    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = "id1", name = "unit1", value = 1 },
        { key = "id2", name = "unit2", value = 1 },
    })
end
