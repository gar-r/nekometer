local _, nekometer = ...

local meter = {
    title = "Damage",
    data = {},
}

function meter:Accept(e)
    if e:isDamage() then
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
    return nekometer.SortMeterData(self.data)
end

function meter:Reset()
    self.data = {}
end

nekometer.damage = meter
