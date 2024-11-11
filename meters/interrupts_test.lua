local lu = require("luaunit")
require("meters/common_test")

local nekometer = {
    baseMeter = BaseMeterMock,
}

loadfile("meters/interrupts.lua")("test", nekometer)

TestInterrupts = {}

local meter = nekometer.meters.interrupts

function TestInterrupts:test_meter()
    local events = {
        {
            IsInterrupt = function() return true end,
            GetSource = function() return { id = "id1", name = "unit1" } end,
        },
        {
            IsInterrupt = function() return false end,
        },
    }
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    lu.assertEquals(meter.recordedData, {
        { key = "id1", name = "unit1", value = 1 },
    })
end
