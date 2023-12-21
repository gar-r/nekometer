local _, nekometer = ...

local pets = {}

nekometer.pets = nekometer.cache:new(21600, function (key)
    if key and key ~= "" then
        return pets:queryOwner(key)
    end
end)


function pets:queryOwner(id)
    local playerPetId = UnitGUID("pet")
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