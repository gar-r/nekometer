local _, nekometer = ...

local pets = {}

nekometer.pets = nekometer.cache:new(3600, function (key)
    return pets:queryOwner(key)
end)


function pets:queryOwner(id)
    local playerPetId = UnitGUID("playerpet")
    if id == playerPetId then
        return {
            id = UnitGUID("player"),
            name = UnitName("player")
        }
    else
        return self:queryTooltipInfo(id)
    end
end

function pets:queryTooltipInfo(id)
    local ttip = C_TooltipInfo.GetHyperlink("unit:" .. id)
    if ttip then
        TooltipUtil.SurfaceArgs(ttip)
        local line = ttip.lines[2]
        if line then
            TooltipUtil.SurfaceArgs(line)
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
            local pattern = string.gsub(g, "%%s's", "(%%a+)'s")
            local _, _, name = string.find(s, pattern)
            if name then
               return {
                id = UnitGUID(name),
                name = name,
            }
            end
        end
        index = index + 1
    until g == nil
end