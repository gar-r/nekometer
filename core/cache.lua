local _, nekometer = ...

local NIL_VALUE = {}

local cache = {}

function cache:new(ttl, loadfn)
    local o = {
        items = {},
        ttl = ttl,
        cleanup = ttl / 5,
        loadfn = loadfn,
    }
    setmetatable(o, self)
    self.__index = self
    o:scheduleNextCleanup()
    return o
end

function cache:Lookup(key)
    local item = self.items[key]
    if not item then
        -- cache miss
        local value, success = self.loadfn(key)
        if success then
            if value == nil then
                self:Set(key, NIL_VALUE)
                return nil
            else
                self:Set(key, value)
                return value
            end
        else
            -- loadfn failed, return nil and don't cache
            return nil
        end
    else
        -- cache hit
        if item.value == NIL_VALUE then
            return nil
        else
            return item.value
        end
    end
end

function cache:Set(key, value)
    self.items[key] = {
        value = value,
        ts = GetTime(),
    }
end

function cache:evict()
    local now = GetTime()
    for key, item in pairs(self.items) do
        if now - item.ts >= self.ttl then
            table[key] = nil
        end
    end
end

function cache:scheduleNextCleanup()
    C_Timer.After(self.cleanup, function()
        self:evict()
        self:scheduleNextCleanup()
    end)
end

nekometer.cache = cache
