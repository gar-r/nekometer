local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/healing_breakdown.lua")("test", nekometer)

TestHealingBreakdown = {}

local meter = nekometer.meters.healingBreakdown

function TestHealingBreakdown:test_combat_event()
    local events = {
        {
            IsDoneByPlayer = function() return true end,
            IsHeal = function() return true end,
            GetAbility = function() return { id = 1, name = "ability1" } end,
            GetAmount = function() return 150 end,
        },
        {
            IsDoneByPlayer = function() return true end,
            IsHeal = function() return false end,
            IsAbsorb = function() return true end,
            GetAbility = function() return { id = 2, name = "ability2" } end,
            GetAmount = function() return 500 end,
        },
        {
            IsDoneByPlayer = function() return false end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = 1, name = "ability1", value = 150 },
        { key = 2, name = "ability2", value = 500 },
    })
end
