local lu = require("luaunit")

local nekometer = {}
loadfile("core/aggregator.lua")("test", nekometer)

TestAggregator = {}

function TestAggregator:test_new()
    local aggregator = nekometer.aggregator:new()
    lu.assertEquals(aggregator.data, {})
end

function TestAggregator:test_add()
    local aggregator = nekometer.aggregator:new()

    aggregator:Add({ key = "test", value = 1 })
    lu.assertEquals(aggregator.data, { test = { key = "test", value = 1 } })

    aggregator:Add({ key = "test", value = 2 })
    lu.assertEquals(aggregator.data, { test = { key = "test", value = 3 } })

    aggregator:Add({ key = "test", value = -4 })
    lu.assertEquals(aggregator.data, { test = { key = "test", value = -1 } })

    -- no key present
    aggregator:Add({ foo = "bar" })
    lu.assertEquals(aggregator.data, { test = { key = "test", value = -1 } })

    -- no value present
    aggregator:Add({ key = "test" })
    lu.assertEquals(aggregator.data, { test = { key = "test", value = -1 } })
end

function TestAggregator:test_get_data()
    local aggregator = nekometer.aggregator:new()
    aggregator:Add({ key = "test1", value = 1 })
    aggregator:Add({ key = "test2", value = 2 })
    local expected = {
        test1 = { key = "test1", value = 1 },
        test2 = { key = "test2", value = 2 },
    }
    lu.assertEquals(aggregator:GetData(), expected)
end

function TestAggregator:test_clear()
    local aggregator = nekometer.aggregator:new()
    aggregator:Add({ key = "test1", value = 1 })
    aggregator:Clear()
    lu.assertEquals(aggregator.data, {})
end