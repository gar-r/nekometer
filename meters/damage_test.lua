local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/damage.lua")("test", nekometer)

TestDamage = {}

local meter = nekometer.meters.damage

function TestDamage:test_meter()
    local events = {
        {
            IsDamage = function() return true end,
            GetSource = function() return { id = 1, name = "unit1" } end,
            GetAmount = function() return 150 end,
        },
        {
            IsDamage = function() return false end,
            IsSpellReflect = function() return true end,
            GetSource = function() return { id = 2, name = "unit2" } end,
            GetAmount = function() return 1000 end,
        },
        {
            IsDamage = function() return false end,
            IsSpellReflect = function() return false end,
            IsAbsorb = function() return false end,
        },
        {
            IsDamage = function() return false end,
            IsSpellReflect = function() return false end,
            IsAbsorb = function() return true end,
            IsSourceFriendly = function() return true end,
            GetSource = function() return { id = 2, name = "unit2" } end,
            GetAmount = function() return 200 end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = 1, name = "unit1", value = 150 },
        { key = 2, name = "unit2", value = 1000 },
        { key = 2, name = "unit2", value = 200 },
    })
end
