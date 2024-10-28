local _, nekometer = ...

local pets = {}

nekometer.pets = nekometer.cache:new(1800, function (key)
    if not key or key == "" then
        return nil, false
    end
    return pets:queryOwner(key), true
end)

function pets:queryOwner(id)
    local playerPetId = UnitGUID("pet")
    if id == playerPetId then
        return {
            id = UnitGUID("player"),
            name = UnitName("player")
        }
    else
        -- in case the creature is not the player's pet, and dispatcher didn't
        -- witness the summoning event, we fall back to using the tooltip
        return self:queryTooltipInfo(id)
    end
end

function pets:queryTooltipInfo(id)
    local ttip = C_TooltipInfo.GetHyperlink("unit:" .. id)
    if ttip then
        local line = ttip.lines[2]
        if line then
            local owner = self:matchTooltipText(line.leftText)
            if owner then
                return owner
            end
        end
    end
end

function pets:matchTooltipText(s)
    local index = 1
    repeat
        local g = _G[format("UNITNAME_SUMMON_TITLE%i", index)]
        if g then
            local pattern = string.gsub(g, "%%s", "(%%a+)")
            local _, _, name = string.find(s, pattern)
            if name and name ~= "" then
                local id = UnitGUID(name)
                if id then
                    return {
                        id = id,
                        name = name,
                    }
                end
            end
        end
        index = index + 1
    until g == nil
end

nekometer.pets_obj = pets