local lu = require('luaunit')

local mockFilter = {}

local nekometer = {
    filter = mockFilter,
}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/deaths.lua')("test", nekometer)

TestDeaths = {}

local events = {
    {
        IsFriendlyDeath = function() return true end,
        [8] = "id1",
        [9] = "unit1",
        [10] = 1,
    },
    {
        IsFriendlyDeath = function() return true end,
        [8] = "id1",
        [9] = "unit1",
        [10] = 1,
    },
    {
        IsFriendlyDeath = function() return true end,
        [8] = "id2",
        [9] = "unit2",
        [10] = 1,
    },
    {
        IsFriendlyDeath = function() return true end,
        [8] = "id3",
        [9] = "unit3",
        [10] = 10,  -- mock isOwned flag, will be skipped
    },
}

local meter = nekometer.meters.deaths

function TestDeaths:test_meter()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter:Report(), {
        { id = "id1", name = "unit1", value = 2 },
        { id = "id2", name = "unit2", value = 1 },
        source = meter,
    })
    meter:Reset()
    lu.assertEquals(meter:Report(), {
        source = meter,
    })
end

function mockFilter:IsOwned(flags)
    return flags == 10
end