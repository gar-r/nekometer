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
    local key = item.key
    if key then
        local value = item.value or 0
        local data = self.data
        if data[key] then
            data[key].value = data[key].value + value
        else
            data[key] = item
        end
    end
end

function aggregator:GetData()
    return self.data
end

function aggregator:Clear()
    self.data = {}
end

nekometer.aggregator = aggregator