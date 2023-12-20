local _, nekometer = ...

local meter = {
    title = "Healing",
    data = {},
}

function meter:Accept(e)
    if e:isHeal() then
        local data = self.data
        if data[e.sourceId] then
            data[e.sourceId].value = data[e.sourceId].value + e.amount
        else
            data[e.sourceId] = {
                name = e.sourceName,
                value = e.amount
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
nekometer.meters.healing = meter
