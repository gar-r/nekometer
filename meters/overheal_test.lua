local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/overheal.lua')("test", nekometer)

TestOverheal = {}

local events = {
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = "id1", name = "unit1" } end,
        [16] = 250,
    },
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = "id1", name = "unit1" } end,
        [16] = 200,
    },
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = "id2", name = "unit2" } end,
        [16] = 1000,
    },
    {
        IsHeal = function() return false end,
    },
}

local meter = nekometer.meters.overheal

function TestOverheal:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = "id2", name = "unit2", value = 1000 },
        { id = "id1", name = "unit1", value = 450 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end
