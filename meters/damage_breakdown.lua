local _, nekometer = ...

local meter = {
    title = "Damage Breakdown",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsDamage() and e:IsDoneByPlayer() then
        local ability = self:getAbilityName(e)
        local amount = e:GetAmount()
        local data = self.data
        if data[ability] then
            data[ability].value = data[ability].value + amount
        else
            data[ability] = {
                name = ability,
                value = amount,
            }
        end
    end
end

-- Return the ability name associated with the event.
function meter:getAbilityName(e)
    local type = e:GetType()
    if type == "SWING_DAMAGE" then
        return "Melee"
    else
        return e[13]
    end
end

function meter:Report()
    return nekometer.CreateReport(self.data, false)
end

function meter:Reset()
    self.data = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damage_breakdown = meter
