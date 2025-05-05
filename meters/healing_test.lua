local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/healing.lua")("test", nekometer)

TestHealing = {}

local meter = nekometer.meters.healing

function TestHealing:test_meter()
    local events = {
        {
            IsHeal = function() return true end,
            GetSource = function() return { id = 1, name = "unit1" } end,
            GetAmount = function() return 100 end,
        },
        {
            IsHeal = function() return false end,
            IsFriendlyAbsorb = function() return true end,
            GetSource = function() return { id = 2, name = "unit2" } end,
            GetAmount = function() return 300 end,
        },
        {
            IsHeal = function() return false end,
            IsFriendlyAbsorb = function() return false end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = 1, name = "unit1", value = 100 },
        { key = 2, name = "unit2", value = 300 },
    })
end
