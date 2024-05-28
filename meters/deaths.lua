local _, nekometer = ...

local meter = {
    title = "Deaths",
    data = {},
}

local filter = nekometer.filter

function meter:CombatEvent(e)
    if e:IsFriendlyDeath() and not filter:IsOwned(e[10]) then
        local dest = {
            id = e[8],
            name = e[9],
        }
        local data = self.data
        if data[dest.id] then
            data[dest.id].value = data[dest.id].value + 1
        else
            data[dest.id] = {
                name  = dest.name,
                value = 1,
            }
        end
    end
end

function meter:Report()
    return nekometer.CreateReport(self.data)
end

function meter:Reset()
    self.data = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.deaths = meter
