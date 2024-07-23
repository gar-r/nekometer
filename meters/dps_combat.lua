local _, nekometer = ...

local meter = {
    title = "Dps (combat)",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        local data = self.data
        if data[source.id] then
            data[source.id].value = data[source.id].value + amount
        else
            data[source.id] = {
                name = source.name,
                value = amount,
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
        return {} -- no combat since start
    end
    local duration
    if self.combatEnd then
        duration = self.combatEnd - self.combatStart
    else
        -- still in combat, so we use the current time
        duration = GetTime() - self.combatStart
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
nekometer.meters.dpsCombat = meter
