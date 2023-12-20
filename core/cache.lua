local _, nekometer = ...

local cache = {}

function cache:new(ttl, loadfn)
    local o = {
        items = {},
        ttl = ttl,
        cleanup = 300,
        loadfn = loadfn,
    }
    setmetatable(o, self)
    self.__index = self
    o:scheduleNextCleanup()
    return o
end

function cache:Lookup(key)
    local item = self.items[key]
    if item then
        item.ts = GetTime()
        return item.value
    else
        item = {
            value = self.loadfn(key),
            ts = GetTime(),
        }
        self.items[key] = item
        return item.value
    end
end

function cache:evict()
    local now = GetTime()
    for key, item in pairs(self.items) do
        if now - item.ts > self.ttl then
            table[key] = nil
        end
    end
    self:scheduleNextCleanup()
end

function cache:scheduleNextCleanup()
    C_Timer.After(self.cleanup, function ()
        self:evict()
    end)
end

nekometer.cache = cache