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
    self:Reset()
    self.combatStart = GetTime()
end

function meter:CombatExited()
    self.combatEnd = GetTime()
end

function meter:Report()
    if not self.combatStart then
        return {}   -- no combat since start 
    end
    local duration
    if self.combatEnd then
        duration = self.combatEnd - self.combatStart
    else
        -- still in combat, so we use the current time
        duration = GetTime() - self.combatStart
    end
    if duration < 0 then
        print("duration", duration)
    end
    local dps = {}
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
    if self.combatStart and not self.combatEnd then
        self.combatStart = GetTime()
    else
        self.combatStart = nil
    end
    self.combatEnd = nil
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dps_combat = meter
