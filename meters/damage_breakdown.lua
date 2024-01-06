local _, nekometer = ...

local meter = {
    title = "Damage Breakdown",
    data = {},
}

local pets = nekometer.pets
local playerId = UnitGUID("player")

function meter:Accept(e)
    if e:isDamage() and self:isPlayerOrPet(e) then
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

function meter:isPlayerOrPet(e)
    return e.sourceId == playerId or pets:Lookup(e.sourceId).id == playerId
end

function meter:Report()
    return nekometer.CreateReport(self.data, false)
end

function meter:Reset()
    self.data = {}
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damage_breakdown = meter
