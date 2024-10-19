local _, nekometer = ...

local meter = {
    title = "Damage",
    aggregator = nekometer.aggregator:new(),
}

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        self.aggregator:Add({
            key = source.id,
            name = source.name,
            value = amount,
        })
    end
end

function meter:Report()
    local data = self.aggregator:GetData()
    return nekometer.CreateReport(data, self)
end

function meter:Reset()
    self.aggregator:Clear()
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.damage = meter
