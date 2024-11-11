local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Damage Breakdown"
meter.reportsAbilities = true

function meter:CombatEvent(e)
    if e:IsDoneByPlayer() and (e:IsDamage() or e:IsSpellReflect()) then
        local ability = e:GetAbility()
        local amount = e:GetAmount()
        self:RecordData({
            key = ability.id,
            name = ability.name,
            value = amount,
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damageBreakdown = meter
