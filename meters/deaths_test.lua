local lu = require("luaunit")
require("meters/common_test")

local mockFilter = {}

local nekometer = {
    baseMeter = BaseMeterMock,
    filter = mockFilter,
}

loadfile("meters/deaths.lua")("test", nekometer)

TestDeaths = {}

local meter = nekometer.meters.deaths

function TestDeaths:test_combat_event()
    local events = {
        {
            IsFriendlyDeath = function() return true end,
            [8] = "id1",
            [9] = "unit1",
            [10] = 1,
        },
        {
            IsFriendlyDeath = function() return false end,
        },
        {
            IsFriendlyDeath = function() return true end,
            [8] = "id3",
            [9] = "unit3",
            [10] = 10, -- mock isOwned flag, will be skipped
        },
    }

    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = "id1", name = "unit1", value = 1 },
    })
end

function mockFilter:IsOwned(flags)
    return flags == 10
end
