local _, nekometer = ...

local parser = {
    meters = {}
}

local playerId = UnitGUID("player")

function parser:AddMeter(meter)
    table.insert(self.meters, meter)
end

function parser:HandleCombatEvent()
    local event = { CombatLogGetCurrentEventInfo() }
    if self:canHandle(event) then
        local subevent = event[2]
        local handler = self[subevent]
        if handler then
            local data = handler(self, event)
            self:updateMeters(data)
        end
    end
end

function parser:canHandle(event)
    local sourceId = event[4]
    return sourceId == playerId
end

function parser:updateMeters(data)
    for _, meter in ipairs(self.meters) do
        meter:Accept(data)
    end
end

function parser:SPELL_DAMAGE(event)
    return {
        sourceId = event[4],
        sourceName = event[5],
        destId = event[8],
        destName = event[9],
        amount = event[15] or 0,
        ability = event[13],
    }
end

function parser:SPELL_PERIODIC_DAMAGE(event)
    return self:SPELL_DAMAGE(event)
end

nekometer.parser = parser
