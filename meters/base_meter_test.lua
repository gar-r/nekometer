local lu = require("luaunit")

local nekometer = {}

loadfile("core/aggregator.lua")("test", nekometer)
loadfile("core/report.lua")("test", nekometer)
loadfile("meters/base_meter.lua")("test", nekometer)

TestBaseMeter = {}

function TestBaseMeter:test_new()
    local obj = nekometer.baseMeter:new()
    lu.assertNotNil(obj)
    lu.assertNotNil(obj.total)
    lu.assertNotNil(obj.current)
end

function TestBaseMeter:test_record_data()
    local obj = nekometer.baseMeter:new()
    obj:RecordData({ key = "foo", value = 15 })
    obj:RecordData({ key = "bar", value = 15 })
    obj:RecordData({ key = "foo", value = 5 })
    obj:RecordData({ key = "foo", value = 5 })
    local expected = {
        foo = { key = "foo", value = 25 },
        bar = { key = "bar", value = 15 },
    }
    lu.assertEquals(obj.current:GetData(), expected)
    lu.assertEquals(obj.total:GetData(), expected)
end

function TestBaseMeter:test_combat_entered()
    local obj = nekometer.baseMeter:new()
    obj:RecordData({ key = "foo", value = 15 })
    obj:CombatEntered()
    lu.assertEquals(obj.current:GetData(), {})
    lu.assertEquals(obj.total:GetData(), {
        foo = { key = "foo", value = 15 }
    })
end

function TestBaseMeter:test_report()
    local obj = nekometer.baseMeter:new()
    obj:RecordData({ key = "foo", value = 15 })
    obj:RecordData({ key = "bar", value = 50 })
    obj:CombatEntered()
    obj:RecordData({ key = "foo", value = 5 })

    local mode = "total"
    nekometer.getMode = function() return mode end

    lu.assertEquals(obj:Report(), {
        { id = "bar", value = 50 },
        { id = "foo", value = 20 },
        source = obj,
    })

    mode = "combat"
    lu.assertEquals(obj:Report(), {
        { id = "foo", value = 5 },
        source = obj,
    })
end

function TestBaseMeter:test_reset()
    local obj = nekometer.baseMeter:new()
    obj:RecordData({ key = "foo", value = 15 })
    obj:Reset()
    lu.assertEquals(obj.current:GetData(), {})
    lu.assertEquals(obj.total:GetData(), {})
end
