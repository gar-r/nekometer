local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Interrupts"

function meter:CombatEvent(e)
    if e:IsInterrupt() then
        local source = e:GetSource()
        self:RecordData({
            key = source.id,
            name = source.name,
            value = 1,
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.interrupts = meter
