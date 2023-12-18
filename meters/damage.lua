local _, nekometer = ...

local meter = {
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

function meter:PrintAll()
    print("Damage Totals:")
    for _, v in pairs(self.data) do
        print(v.name .. ": " .. v.value)
    end
end

nekometer.damage = meter
