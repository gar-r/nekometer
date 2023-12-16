local _, nekometer = ...

local dps = {
    enabled = false,
    refresh = 1,
    smoothing = 0.7,
    data = {},
    dps = {},
}

function dps:Accept(e)
    local data = self.data
    if data[e.sourceId] then
        data[e.sourceId].value = data[e.sourceId].value + e.amount
    else
        data[e.sourceId] = {
            name = e.sourceName,
            value = e.amount,
        }
    end
end

function dps:Refresh()
    for id, d in pairs(self.data) do
        -- also apply exponential smoothing while recording the data
        local next = math.floor(self.smoothing * d.value / self.refresh)
        if self.dps[id] then
            local rec = self.dps[id]
            rec.value = next + math.floor((1 - self.smoothing) * rec.value)
        else
            self.dps[id] = {
                name = d.name,
                value = next
            }
        end
        d.value = 0
    end
end

function dps:Ticker()
    self:Refresh()
    self:PrintAll()
    if self.enabled then
        C_Timer.After(self.refresh, function()
            self:Ticker()
        end)
    end
end

function dps:Init()
    self.enabled = true
    self:Ticker()
end

function dps:PrintAll()
    print("Dps:")
    for _, v in pairs(self.dps) do
        print(v.name .. ": " .. v.value)
    end
end

nekometer.dps = dps
