local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Damage Breakdown"
meter.reportsAbilities = true

function meter:CombatEvent(e)
    if not e:IsDoneByPlayer() then
        return
    end
    if e:IsDamage() or e:IsSpellReflect() or
        e:IsAbsorb() and e:IsSourceFriendly() then
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
