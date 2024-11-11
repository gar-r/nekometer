local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/damage_breakdown.lua")("test", nekometer)

TestDamageBreakdown = {}

local meter = nekometer.meters.damageBreakdown

function TestDamageBreakdown:test_combat_event()
    local events = {
        {
            IsDoneByPlayer = function() return true end,
            IsDamage = function() return true end,
            GetAbility = function() return { id = 1, name = "ability1" } end,
            GetAmount = function() return 150 end,
        },
        {
            IsDoneByPlayer = function() return true end,
            IsDamage = function() return false end,
            IsSpellReflect = function() return true end,
            GetAbility = function() return { id = 2, name = "ability2" } end,
            GetAmount = function() return 1000 end,
        },
        {
            IsDoneByPlayer = function() return false end,
        },
        {
            IsDoneByPlayer = function() return true end,
            IsDamage = function() return false end,
            IsSpellReflect = function() return false end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = 1, name = "ability1", value = 150 },
        { key = 2, name = "ability2", value = 1000 },
    })
end
