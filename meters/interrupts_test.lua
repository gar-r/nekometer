local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/interrupts.lua')("test", nekometer)

TestInterrupts = {}

local events = {
    {
        IsInterrupt = function() return true end,
        GetSource = function() return { id = "id1", name = "unit1" } end,
    },
    {
        IsInterrupt = function() return true end,
        GetSource = function() return { id = "id1", name = "unit1" } end,
    },
    {
        IsInterrupt = function() return true end,
        GetSource = function() return { id = "id2", name = "unit2" } end,
    },
    {
        IsInterrupt = function() return false end,
    },
}

local meter = nekometer.meters.interrupts

function TestInterrupts:test_meter()
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
