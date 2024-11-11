local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Overhealing"

function meter:CombatEvent(e)
    if e:IsHeal() then
        local source = e:GetSource()
        self:RecordData({
            key = source.id,
            name = source.name,
            value = e[16],
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.overheal = meter
