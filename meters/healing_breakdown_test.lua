local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/healing_breakdown.lua')("test", nekometer)

TestHealingBreakdown = {}

local events = {
    {
        IsDoneByPlayer = function() return true end,
        IsHeal = function() return true end,
        GetAbility = function() return { id = 1, name = "ability1" } end,
        GetAmount = function() return 150 end,
    },
    {
        IsDoneByPlayer = function() return true end,
        IsHeal = function() return true end,
        GetAbility = function() return { id = 2, name = "ability2" } end,
        GetAmount = function() return 1000 end,
    },
    {
        IsDoneByPlayer = function() return true end,
        IsHeal = function() return false end,
        IsAbsorb = function() return true end,
        GetAbility = function() return { id = 3, name = "ability3" } end,
        GetAmount = function() return 500 end,
    },
    {
        IsDoneByPlayer = function() return false end,
    }
}

local meter = nekometer.meters.healingBreakdown

function TestHealingBreakdown:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = 2, name = "ability2", value = 1000 },
        { id = 3, name = "ability3", value = 500 },
        { id = 1, name = "ability1", value = 150 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end