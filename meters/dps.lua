local _, nekometer = ...

local meter = {
    enabled = false,
    default_refresh = 1,
    default_smoothing = 0.7,
    data = {},
    dps = {},
}

function meter:Accept(e)
    if e:isDamage() then
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
end

function meter:Refresh()
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

function meter:ticker()
    self:Refresh()
    if self.enabled then
        C_Timer.After(self.refresh, function()
            self:ticker()
        end)
    end
end

function meter:Init(cfg)
    self.enabled = true
    self.refresh = cfg.dps_refresh or self.default_refresh
    self.smoothing = cfg.dps_smoothing or self.default_smoothing
    self:ticker()
end

function meter:PrintAll()
    print("Dps:")
    for _, v in pairs(self.dps) do
        print(v.name .. ": " .. v.value)
    end
end

nekometer.dps = meter
