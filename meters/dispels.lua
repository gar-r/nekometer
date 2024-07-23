local _, nekometer = ...

local meter = {
    title = "Dispels",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsDispel() then
        local source = e:GetSource()
        local data = self.data
        if data[source.id] then
            data[source.id].value = data[source.id].value + 1
        else
            data[source.id] = {
                name  = source.name,
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
nekometer.meters.dispels = meter
