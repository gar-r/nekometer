local _, nekometer = ...

local meter = {
    title = "Dps (current)",
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

function meter:CombatExited()
    self:Reset()
end

function meter:Refresh()
    for id, d in pairs(self.data) do
        -- also apply exponential smoothing while recording the data
        local next = math.floor(self.smoothing * d.value / self.window)
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
    C_Timer.After(self.window, function()
        self:ticker()
    end)
end

function meter:Init(cfg)
    self.window = cfg.window
    self.smoothing = cfg.smoothing
    self:ticker()
end

function meter:Report()
    return nekometer.CreateReport(self.dps)
end

function meter:Reset()
    self.data = {}
    self.dps = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dps_current = meter
