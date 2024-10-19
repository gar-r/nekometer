local _, nekometer = ...

local specs = nekometer.specs
local util = nekometer.util

-- cache for (id -> class)
nekometer.classes = nekometer.cache:new(21600, function(key)
    local success, class = pcall(function()
        local _, className = GetPlayerInfoByGUID(key)
        return className
    end)
    return class, success
end)

-- cache for (id -> class icon)
nekometer.classIcons = nekometer.cache:new(21600, function(key)
    -- async call to load the spec icon
    specs:GetSpecializationByID(key)
    return nil, false
end)

-- cache for (ability name -> ability icon)
nekometer.abilityIcons = nekometer.cache:new(21600, function(key)
    return util:GetSpellTexture(key), true
end)