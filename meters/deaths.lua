local _, nekometer = ...

local meter = {
    title = "Deaths",
    aggregator = nekometer.aggregator:new(),
}

local filter = nekometer.filter

function meter:CombatEvent(e)
    if e:IsFriendlyDeath() and not filter:IsOwned(e[10]) then
        local dest = {
            id = e[8],
            name = e[9],
        }
        self.aggregator:Add({
            key = dest.id,
            name = dest.name,
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
nekometer.meters.deaths = meter
