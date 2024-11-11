local lu = require("luaunit")

local mode = "combat"
local nekometer = {
    getMode = function() return mode end,
}

loadfile("core/aggregator.lua")("test", nekometer)
loadfile("core/report.lua")("test", nekometer)
loadfile("meters/dps.lua")("test", nekometer)

TestDps = {}

local meter = nekometer.meters.dps

function TestDps:setUp()
    mode = "total"
    meter:Reset()
end

function TestDps:test_meter_fresh_start()
    mode = "total"
    lu.assertEquals(#meter:Report(), 0)

    mode = "combat"
    lu.assertEquals(#meter:Report(), 0)
end

local events = {
    {
        IsDamage = function() return true end,
        GetSource = function() return { id = 1, name = "unit1" } end,
        GetAmount = function() return 450 end,
    },
    {
        IsDamage = function() return false end,
        IsSpellReflect = function() return true end,
        GetSource = function() return { id = 2, name = "unit2" } end,
        GetAmount = function() return 650 end,
    },
    {
        IsDamage = function() return false end,
        IsSpellReflect = function() return false end,
    },
}


function TestDps:test_meter_time_frame_combat_mode()
    mode = "combat"
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

function TestDps:test_meter_time_frame_total_mode()
    mode = "total"

    -- segment 1
    GetTime = function() return 0 end
    meter:CombatEntered()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    GetTime = function() return 10 end
    meter:CombatExited()

    -- segment 2
    GetTime = function() return 20 end
    meter:CombatEntered()
    for _, e in ipairs(events) do
        meter:CombatEvent(e)
    end
    GetTime = function() return 30 end
    meter:CombatExited()

    -- segment 1 and 2 combined: 10 seconds each, same dps value
    local report = meter:Report()
    lu.assertEquals(report, {
        { id = 2, name = "unit2", value = 65 },
        { id = 1, name = "unit1", value = 45 },
        source = meter,
    })
end


function TestDps:test_meter_reset_during_combat()
    GetTime = function() return 0 end
    meter:CombatEntered()
    GetTime = function() return 5 end
    meter:Reset()
    lu.assertEquals(meter.combatStart, 5)
    lu.assertEquals(meter.combatEnd, nil)
end

function TestDps:test_meter_reset_out_of_combat()
    GetTime = function() return 0 end
    meter:CombatEntered()
    GetTime = function() return 5 end
    meter:CombatExited()
    meter:Reset()
    lu.assertEquals(meter.combatStart, nil)
    lu.assertEquals(meter.combatEnd, nil)
end
