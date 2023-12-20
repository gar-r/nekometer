local _, nekometer = ...

local meter = {
    title = "Dps (current)",
    default_window = 3,
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
    self.window = cfg.dps_window or self.default_window
    self.smoothing = cfg.dps_smoothing or self.default_smoothing
    self:ticker()
end

function meter:Report()
    return nekometer.SortMeterData(self.dps)
end

function meter:Reset()
    self.data = {}
    self.dps = {}
end

nekometer.dps_current = meter
