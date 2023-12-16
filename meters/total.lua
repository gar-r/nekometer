local _, nekometer = ...

local total = {}

function total:Accept(data)
    if total[data.sourceId] then
        total[data.sourceId].total = total[data.sourceId].total + data.amount
    else
        total[data.sourceId] = {
            name = data.sourceName,
            total = 0
        }
    end
end

function total:PrintAll()
    print("Damage Totals:")
    for _, v in pairs(total) do
        print(v.name .. ": " .. v.total)
    end
end

nekometer.total = total
