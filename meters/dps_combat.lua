local _, nekometer = ...

local meter = {
    title = "Dps (combat)",
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
                value = e.amount,
            }
        end
    end
end

function meter:CombatEntered()
    self.combatStart = GetTimePreciseSec()
    self.combatEnd = nil
end

function meter:CombatExited()
    self.combatEnd = GetTimePreciseSec()
end

function meter:Report()
    local dps = {}
    if self.combatStart == nil then
        return {}   -- no combat since start 
    end
    local duration
    if self.combatEnd then
        duration = self.combatEnd - self.combatStart
    else
        -- still in combat, so we use the current time
        duration = GetTimePreciseSec() - self.combatStart
    end
    for k, v in pairs(self.data) do
        dps[k] = {
            name = v.name,
            value = math.floor(v.value / duration)
        }
    end
    return nekometer.CreateReport(dps)
end

function meter:Reset()
    self.data = {}
    if self.combatStart and self.combatEnd == nil then
        self.combatStart = GetTime()
    end
    self.combatEnd = nil
end

nekometer.dps_combat = meter
