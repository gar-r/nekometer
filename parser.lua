local _, nekometer = ...

local parser = {}
local playerId = UnitGUID("player") or ""

function nekometer:ParseCombatLogEvent()
    local event = {CombatLogGetCurrentEventInfo()}
    if not parser:relevant(event) then
        return
    end

    local sourceName = event[5]
    local destName = event[9]
    local spellName = event[13] or "Unknown"
    local amount = event[15] or 0
    local msg = string.format("%s (%s) -> %s (%s)", sourceName, spellName, destName, amount)
    print(msg)
end

function parser:relevant(event)
    return self:isDamageEvent(event) and self:isEntityTracked(event)
end

function parser:isDamageEvent(event)
    local subevent = event[2]
    return subevent == "SWING_DAMAGE"
        or subevent == "RANGE_DAMAGE"
        or subevent == "SPELL_DAMAGE"
        or subevent == "SPELL_PERIODIC_DAMAGE"
end

function parser:isEntityTracked(event)
    local sourceId = event[4]
    return sourceId == playerId or UnitIsEnemy(playerId, sourceId)
end
