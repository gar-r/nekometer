local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/healing.lua')("test", nekometer)

TestHealing = {}

local events = {
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 100 end,
    },
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 200 end,
    },
    {
        IsHeal = function() return false end,
        IsAbsorb = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 300 end,
    },
    {
        IsHeal = function() return true end,
        GetSource = function() return { id = 3, name = "unit3" } end,
        GetAmount = function() return 400 end,
    },
    {
        IsHeal = function() return false end,
        IsAbsorb = function() return false end,
    },
}

local meter = nekometer.meters.healing

function TestHealing:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = 2, name = "unit2", value = 500 },
        { id = 3, name = "unit3", value = 400 },
        { id = 1, name = "unit1", value = 100 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end