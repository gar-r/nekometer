local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Damage"

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() or
        e:IsAbsorb() and e:IsSourceFriendly() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        self:RecordData({
            key = source.id,
            name = source.name,
            value = amount,
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damage = meter
