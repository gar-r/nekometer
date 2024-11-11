local _, nekometer = ...

local meter = nekometer.baseMeter:new()
meter.title = "Deaths"

local filter = nekometer.filter

function meter:CombatEvent(e)
    if e:IsFriendlyDeath() and not filter:IsOwned(e[10]) then
        local dest = {
            id = e[8],
            name = e[9],
        }
        self:RecordData({
            key = dest.id,
            name = dest.name,
            value = 1,
        })
    end
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.deaths = meter
