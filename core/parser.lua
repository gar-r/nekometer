local _, nekometer = ...

local parser = {
    meters = {}
}

function parser:AddMeter(meter)
    if meter.Init then
        meter:Init()
    end
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
    local sourceFlags = event[6]
    local relevant = bit.bor(
        COMBATLOG_FILTER_ME,
        COMBATLOG_FILTER_MY_PET
    )
    return CombatLog_Object_IsA(sourceFlags, relevant)
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

function parser:SWING_DAMAGE(event)
    return {
        sourceId = event[4],
        sourceName = event[5],
        destId = event[8],
        destName = event[9],
        amount = event[12] or 0,
        ability = "Melee",
    }
end

function parser:RANGE_DAMAGE(event)
    return self:SPELL_DAMAGE(event)
end

nekometer.parser = parser
