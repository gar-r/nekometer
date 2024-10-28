local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/dps_current.lua')("test", nekometer)

TestDpsCurrent = {}

local events = {
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 100 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 200 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 150 end,
    },
    {
        IsDamage = function() return false end,
        IsSpellReflect = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 500 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 50 end,
    },
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 100 end,
    },
}

local meter = nekometer.meters.dpsCurrent

function TestDpsCurrent:test_meter()
    meter.window = 1
    meter.smoothing = 0.5
    self:apply_frame_and_verify_report(events[1], {
        { id = 1, name = "unit1", value = 50 },
        source = meter,
    })
    self:apply_frame_and_verify_report(events[2], {
        { id = 1, name = "unit1", value = 125 },
        source = meter,
    })
    self:apply_frame_and_verify_report(events[3], {
        { id = 1, name = "unit1", value = 137 },
        source = meter,
    })
    self:apply_frame_and_verify_report(events[4], {
        { id = 2, name = "unit2", value = 250 },
        { id = 1, name = "unit1", value = 68 },
        source = meter,
    })
    self:apply_frame_and_verify_report(events[5], {
        { id = 2, name = "unit2", value = 150 },
        { id = 1, name = "unit1", value = 34 },
        source = meter,
    })
    self:apply_frame_and_verify_report(events[6], {
        { id = 2, name = "unit2", value = 125 },
        { id = 1, name = "unit1", value = 17 },
        source = meter,
    })
end

function TestDpsCurrent:apply_frame_and_verify_report(event, expected)
    meter:CombatEvent(event)
    meter:Refresh()
    lu.assertEquals(meter:Report(), expected)
end