local lu = require('luaunit')

local nekometer = {}

loadfile('core/aggregator.lua')("test", nekometer)
loadfile('core/report.lua')("test", nekometer)
loadfile('meters/dps_combat.lua')("test", nekometer)

TestDpsCombat = {}

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

local meter = nekometer.meters.dpsCombat

function TestDpsCombat:setUp()
    meter:Reset()
end

function TestDpsCombat:test_meter_fresh_start()
    local report = meter:Report()
    lu.assertEquals(report, {})
end

function TestDpsCombat:test_meter_time_frame()
    GetTime = function() return 0 end
    meter:CombatEntered()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    GetTime = function() return 10 end
    meter:CombatExited()
    local report = meter:Report()
    lu.assertEquals(report, {
        { id = 2, name = "unit2", value = 65 },
        { id = 1, name = "unit1", value = 45 },
        source = meter,
    })
end

function TestDpsCombat:test_meter_reset_during_combat()
    GetTime = function() return 0 end
    meter:CombatEntered()
    GetTime = function() return 5 end
    meter:Reset()
    lu.assertEquals(meter.combatStart, 5)
    lu.assertEquals(meter.combatEnd, nil)
end

function TestDpsCombat:test_meter_reset_out_of_combat()
    GetTime = function() return 0 end
    meter:CombatEntered()
    GetTime = function() return 5 end
    meter:CombatExited()
    meter:Reset()
    lu.assertEquals(meter.combatStart, nil)
    lu.assertEquals(meter.combatEnd, nil)
end