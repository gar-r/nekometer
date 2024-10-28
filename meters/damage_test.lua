local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/damage.lua')("test", nekometer)

TestDamage = {}

local events = {
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 150 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 1000 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 500 end,
    },
    {
        IsDamage = function() return false end,
        IsSpellReflect = function() return true end,
        GetSource = function() return { id = 3, name = "unit3" } end,
        GetAmount = function() return 100 end,
    },
    {
        IsDamage = function() return false end,
        IsSpellReflect = function() return false end,
    },
}

local meter = nekometer.meters.damage

function TestDamage:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = 2, name = "unit2", value = 1500 },
        { id = 1, name = "unit1", value = 150 },
        { id = 3, name = "unit3", value = 100 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end