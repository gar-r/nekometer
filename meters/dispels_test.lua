local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/dispels.lua')("test", nekometer)

TestDispels = {}

local events = {
    {
        IsDispel = function() return true end,
        GetSource = function() return { id = "id1", name = "unit1" } end,
    },
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

local meter = nekometer.meters.dispels

function TestDispels:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = "id1", name = "unit1", value = 2 },
        { id = "id2", name = "unit2", value = 1 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end
