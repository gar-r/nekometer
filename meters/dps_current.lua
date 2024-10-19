local _, nekometer = ...

local meter = {
    title = "Dps (current)",
    aggregator = nekometer.aggregator:new(),
    dps = {},
}

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        self.aggregator:Add({
            key = source.id,
            name = source.name,
            value = amount,
        })
    end
end

function meter:CombatExited()
    self:Reset()
end

function meter:Refresh()
    local data = self.aggregator:GetData()
    for id, d in pairs(data) do
        -- apply exponential smoothing while recording the data
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
    self.window = cfg.dpsCurrentWindowSize
    self.smoothing = cfg.dpsCurrentSmoothing
    self:ticker()
end

function meter:Report()
    return nekometer.CreateReport(self.dps, self)
end

function meter:Reset()
    self.aggregator:Clear()
    self.dps = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dpsCurrent = meter
