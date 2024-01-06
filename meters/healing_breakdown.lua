local _, nekometer = ...

local meter = {
    title = "Healing Breakdown",
    data = {},
}

function meter:Accept(e)
    if e:isHeal() and e:isDoneByPlayer(e) then
        local data = self.data
        if data[e.ability] then
            data[e.ability].value = data[e.ability].value + e.amount
        else
            data[e.ability] = {
                name = e.ability,
                value = e.amount,
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
