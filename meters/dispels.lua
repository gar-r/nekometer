local _, nekometer = ...

local meter = {
    title = "Dispels",
    aggregator = nekometer.aggregator:new(),
}

function meter:CombatEvent(e)
    if e:IsDispel() then
        local source = e:GetSource()
        self.aggregator:Add({
            key = source.id,
            name = source.name,
            value = 1,
        })
    end
end

function meter:Report()
    local data = self.aggregator:GetData()
    return nekometer.CreateReport(data)
end

function meter:Reset()
    self.aggregator:Clear()
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dispels = meter
