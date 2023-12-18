local _, nekometer = ...

--[[
    SortMeterData returns a list of unit ids sorted by meter
    data descending.
    Meter Data is expected to be in the following format:
    { "unitId": { "name": "foo", "value": "bar" }, ... }

]]
nekometer.SortMeterData = function (meterData)
    local sortedIds = {}
    for id in pairs(meterData) do
        table.insert(sortedIds, id)
    end
    table.sort(sortedIds, function (a, b)
        return meterData[a].value > meterData[b].value
    end)
    local sortedValues = {}
    for _, id in ipairs(sortedIds) do
        table.insert(sortedValues, meterData[id])
    end
    return sortedValues
end

nekometer.PrintReport = function (report)
    for i, data in ipairs(report) do
        print(string.format("%2d: %s (%s)", i, data.name, data.value))
    end
end