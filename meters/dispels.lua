local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Dispels"

function meter:CombatEvent(e)
    if e:IsDispel() then
        local source = e:GetSource()
        self:RecordData({
            key = source.id,
            name = source.name,
            value = 1,
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dispels = meter
