local _, nekometer = ...

--[[ This is a common base suitable for most meters.]]
local baseMeter = {}

function baseMeter:new()
    local o = {
        total = nekometer.aggregator:new(),
        current = nekometer.aggregator:new(),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function baseMeter:RecordData(data)
    self.current:Add(data)
    self.total:Add(data)
end

function baseMeter:CombatEntered()
    self.current:Clear()
end

function baseMeter:Report()
    local data = {}
    local mode = nekometer.getMode(self.key)
    if mode == "combat" then
        data = self.current:GetData()
    else
        data = self.total:GetData()
    end
    return nekometer.CreateReport(data, self)
end

function baseMeter:Reset()
    self.total:Clear()
    self.current:Clear()
end

nekometer.baseMeter = baseMeter