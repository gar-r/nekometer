local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/overheal.lua")("test", nekometer)

TestOverheal = {}

local meter = nekometer.meters.overheal

function TestOverheal:test_meter()
    local events = {
        {
            IsHeal = function() return true end,
            GetSource = function() return { id = "id1", name = "unit1" } end,
            [16] = 250,
        },
        {
            IsHeal = function() return false end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = "id1", name = "unit1", value = 250 },
    })
end
