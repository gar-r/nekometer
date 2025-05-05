local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Healing"

function meter:CombatEvent(e)
    if e:IsHeal() or e:IsFriendlyAbsorb() then
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
nekometer.meters.healing = meter
