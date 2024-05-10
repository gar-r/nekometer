local _, nekometer = ...

local meter = {
    title = "Damage Breakdown",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsDoneByPlayer() and (e:IsDamage() or e:IsSpellReflect()) then
        local ability = e:GetAbilityName()
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

function meter:Report()
    return nekometer.CreateReport(self.data, false)
end

function meter:Reset()
    self.data = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damage_breakdown = meter
