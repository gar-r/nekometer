local _, nekometer = ...

nekometer.classes = nekometer.cache:new(21600, function (key)
    local success, class = pcall(function ()
        local _, className = GetPlayerInfoByGUID(key)
        return className
    end)
    if success then
        return class
    end
end)

--[[
    Transforms the meter data into a report that the UI can
    interpret and display as bars.
    
    The "meterData" argument is expected to be an associative table 
    in the following format:
    { 
        unitId: {
            name": "foo",
            value: 12345,
        }, 
    }

    Elements in the resulting indexed table are sorted 
    by value in descending order, and have the following schema:
    {
        name: "foo",
        value: 12345,
        class: "Shaman",
    }
    Note: the "class" attribute is only populated when enabled in the config.
]]
nekometer.CreateReport = function (meterData)
    local sortedIds = {}
    for id in pairs(meterData) do
        table.insert(sortedIds, id)
    end
    table.sort(sortedIds, function (a, b)
        return meterData[a].value > meterData[b].value
    end)
    local sortedValues = {}
    for _, id in ipairs(sortedIds) do
        local data = meterData[id]
        if NekometerConfig.classColors then
            data.class = nekometer.classes:Lookup(id)
        end
        table.insert(sortedValues, data)
    end
    return sortedValues
end

-- Outputs the report to the console.
-- Mostly used for debugging.
nekometer.PrintReport = function (report)
    for i, data in ipairs(report) do
        if data.name and data.value then
            print(string.format("%2d: %s (%s)", i, data.name, data.value))
        end
    end
end
