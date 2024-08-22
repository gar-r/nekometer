local _, nekometer = ...

local meter = {
    title = "Overhealing",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsHeal() then
        local source = e:GetSource()
        local amount = e[16]
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

function meter:Report()
    return nekometer.CreateReport(self.data)
end

function meter:Reset()
    self.data = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.overheal = meter
