local _, nekometer = ...

local aggregator = {}

--[[
Meter data aggregator. Data is expected to have at least the following fields:
    { key, value }
]]
function aggregator:new()
    local o = {
        data = {},
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function aggregator:Add(item)
    if not item.key then
        return
    end
    local i = self:copy(item)
    i.value = i.value or 0
    local d = self.data[i.key]
    if not d then
        self.data[i.key] = i
    else
        d.value = d.value + i.value
    end
end

function aggregator:GetData()
    return self.data
end

function aggregator:Clear()
    self.data = {}
end

-- create a shallow copy of the item
function aggregator:copy(item)
    local res = {}
    for k, v in pairs(item) do
        res[k] = v
    end
    return res
end

nekometer.aggregator = aggregator
