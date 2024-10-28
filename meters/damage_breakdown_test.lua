local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/damage_breakdown.lua')("test", nekometer)

TestDamageBreakdown = {}

local events = {
    {
        IsDoneByPlayer = function() return true end,
        IsDamage = function() return true end,
        GetAbility = function() return { id = 1, name = "ability1" } end,
        GetAmount = function() return 150 end,
    },
    {
        IsDoneByPlayer = function() return true end,
        IsDamage = function() return true end,
        GetAbility = function() return { id = 2, name = "ability2" } end,
        GetAmount = function() return 1000 end,
    },
    {
        IsDoneByPlayer = function() return true end,
        IsDamage = function() return true end,
        GetAbility = function() return { id = 2, name = "ability2" } end,
        GetAmount = function() return 500 end,
    },
    {
        IsDoneByPlayer = function() return true end,
        IsDamage = function() return false end,
        IsSpellReflect = function() return true end,
        GetAbility = function() return { id = 3, name = "ability3" } end,
        GetAmount = function() return 100 end,
    },
    {
        IsDoneByPlayer = function() return false end,
    },
}

local meter = nekometer.meters.damageBreakdown

function TestDamageBreakdown:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = 2, name = "ability2", value = 1500 },
        { id = 1, name = "ability1", value = 150 },
        { id = 3, name = "ability3", value = 100 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end