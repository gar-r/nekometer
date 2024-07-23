local _, nekometer = ...

local meter = {
    title = "Dps (current)",
    data = {},
    dps = {},
}

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        local data = self.data
        if data[source.id] then
            data[source.id].value = data[source.id].value + amount
        else
            data[source.id] = {
                name = source.name,
                value = amount,
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
    self.window = cfg.dpsCurrentWindowSize
    self.smoothing = cfg.dpsCurrentSmoothing
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
nekometer.meters.dpsCurrent = meter
