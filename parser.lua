local _, nekometer = ...

nekometer.damage = {}

local parser = {}
local playerId = UnitGUID("player") or ""

function nekometer:RecordCombatLogEvent()
    local event = {CombatLogGetCurrentEventInfo()}
    if parser:isEntityTracked(event) then
        parser:record(event)
    end
end

function parser:isEntityTracked(event)
    local sourceId = event[4]
    return sourceId == playerId
end

function parser:record(event)
    local subevent = event[2]
    local fn = self[subevent]
    if fn then
        fn(self, event)
    end
end

function parser:SPELL_DAMAGE(event)
    local sourceName = event[5]
    local amount = event[15] or 0
    local current = nekometer.damage[sourceName] or 0
    nekometer.damage[sourceName] = current + amount
end

function parser:SPELL_PERIODIC_DAMAGE(event)
    self:SPELL_DAMAGE(event)
end
