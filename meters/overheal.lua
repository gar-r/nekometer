local _, nekometer = ...

local meter = {
    title = "Overhealing",
    aggregator = nekometer.aggregator:new(),
}

function meter:CombatEvent(e)
    if e:IsHeal() then
        local source = e:GetSource()
        self.aggregator:Add({
            key = source.id,
            name = source.name,
            value = e[16],
        })
    end
end

function meter:Report()
    local data = self.aggregator:GetData()
    return nekometer.CreateReport(data, self)
end

function meter:Reset()
    self.aggregator:Clear()
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.overheal = meter
