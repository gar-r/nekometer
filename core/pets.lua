local _, nekometer = ...

local pets = {
    cache = {}
}

function pets:GetOwner(id)
    local owner = self:cacheLookup(id)
    if owner == nil then
        owner = self:queryOwner(id)
        self.cache[id] = owner
    end
    return owner
end

function pets:ClearCache()
    self.cache = {}
end

function pets:cacheLookup(id)
    return self.cache[id]
end

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

nekometer.pets = pets

