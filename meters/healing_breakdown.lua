local _, nekometer = ...

local meter = {
    title = "Healing Breakdown",
    data = {},
}

function meter:CombatEvent(e)
    if e:IsHeal() and e:IsDoneByPlayer() then
        local ability = e[13]
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
nekometer.meters.healing_breakdown = meter
