local _, nekometer = ...

local parser = {}

--[[
    Parse the combat event into a standard data packet.
    Users of the packet don't need to be aware of the  
    actual indices in the event.
       data = { 
            sourceId, sourceName,
            destId, destName,
            ability, amount,
            type
        }
]]
function parser:Parse(event)
    local subevent = event[2]
    local handler = self[subevent]
    if handler then
        return handler(self, event)
    end
end

function parser:SPELL_DAMAGE(event)
    local data = self:parseActors(event)
    data.ability = event[13]
    data.amount = event[15] or 0
    data.type = nekometer.EVENT_TYPE_DAMAGE
    return data
end

function parser:SPELL_PERIODIC_DAMAGE(event)
    return self:SPELL_DAMAGE(event)
end

function parser:RANGE_DAMAGE(event)
    return self:SPELL_DAMAGE(event)
end

function parser:SPELL_HEAL(event)
    local data = self:SPELL_DAMAGE(event)
    data.type = nekometer.EVENT_TYPE_HEAL
    return data
end

function parser:SWING_DAMAGE(event)
    local data = self:parseActors(event)
    data.amount = event[12] or 0
    data.ability = "Melee"
    data.type = nekometer.EVENT_TYPE_DAMAGE
    return data
end

function parser:parseActors(event)
    return nekometer.event:new({
        sourceId = event[4],
        sourceName = event[5],
        destId = event[8],
        destName = event[9],
    })
end

nekometer.parser = parser

