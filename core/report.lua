local _, nekometer = ...

nekometer.ReportTypes = {
    PLAYERS = "players",
    ABILITIES = "abilities",
}

--[[
    Flattens the meter data into a single ordered (descending) table.
    For example, for the following meter data:
    {
        "key-0123": {
            name": "foo",
            value: 12345,
        },
    }
    The resulting table would be:
    {
        {
            id: "key-0123",    
            name: "foo",
            value: 12345,
        },
    }
]]
nekometer.CreateReport = function(meterData, source)
    local sortedIds = {}
    for id in pairs(meterData) do
        table.insert(sortedIds, id)
    end
    table.sort(sortedIds, function(a, b)
        return meterData[a].value > meterData[b].value
    end)
    local report = {}
    for _, id in ipairs(sortedIds) do
        local data = meterData[id]
        data.id = id
        data.key = nil
        table.insert(report, data)
    end
    report.source = source
    return report
end

-- Outputs the report to the console.
-- Mostly used for debugging.
nekometer.PrintReport = function(report)
    for i, data in ipairs(report) do
        if data.name and data.value then
            print(string.format("%2d: %s (%s)", i, data.name, data.value))
        end
    end
end
