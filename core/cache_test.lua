local lu = require("luaunit")

local nekometer = {}

loadfile("core/cache.lua")("test", nekometer)

TestCache = {}

function TestCache:setUp()
    GetTime = function() return 0 end
    C_Timer = {
        After = function(_, _) end
    }
end

function TestCache:test_lookup_cache_miss()
    local lookupFnCalled = false
    local cache = nekometer.cache:new(1000, function()
        lookupFnCalled = true
        return 1, true
    end)
    lu.assertEquals(cache:Lookup("key"), 1)
    lu.assertTrue(lookupFnCalled)
end

function TestCache:test_lookup_cache_hit()
    local lookupFnCalls = 0
    local cache = nekometer.cache:new(1000, function()
        lookupFnCalls = lookupFnCalls + 1
        return 1, true
    end)
    lu.assertEquals(cache:Lookup("key"), 1)
    lu.assertEquals(cache:Lookup("key"), 1)
    lu.assertEquals(cache:Lookup("key"), 1)
    lu.assertEquals(lookupFnCalls, 1)
end

function TestCache:test_lookup_load_nil_value()
    local cache = nekometer.cache:new(1000, function()
        return nil, true
    end)
    lu.assertEquals(cache:Lookup("key"), nil)
end

function TestCache:test_lookup_load_fail()
    local loadFnCalls = 0
    local cache = nekometer.cache:new(1000, function()
        loadFnCalls = loadFnCalls + 1
        return 1, false
    end)
    lu.assertEquals(cache:Lookup("key"), nil)
    lu.assertEquals(cache:Lookup("key"), nil)
    lu.assertEquals(cache:Lookup("key"), nil)
    lu.assertEquals(loadFnCalls, 3)
end

function TestCache:test_set_value()
    local cache = nekometer.cache:new(1000, function() end)
    cache:Set("key", 2)
    lu.assertEquals(cache:Lookup("key"), 2)
end

function TestCache:test_set_nil_value()
    local cache = nekometer.cache:new(1000, function() end)
    cache:Set("key", nil)
    lu.assertEquals(cache:Lookup("key"), nil)
end

function TestCache:test_cache_eviction()
    -- create cache with 0 sec ttl, causing immediate expiration
    local cache = nekometer.cache:new(0, function() end)
    cache:Set("key", 1)
    cache:evict()
    lu.assertEquals(cache.items, {})
end
