local _, nekometer = ...

local parser = {}

local pets = nekometer.pets
local util = nekometer.util

--[[
    Parse the WoW combat event into a custom event packet.
    Users of the packet don't need to be aware of the  
    actual indices in the WoW event.
       event = { 
            sourceId, sourceName,
            destId, destName,      
            ownerId, ownerName,      
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

function parser:SPELL_PERIODIC_HEAL(event)
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
    local sourceId = event[4]
    local sourceName = event[5]
    if self:hasOwner(event) then
        local isPet = self:isPet(event)
        if not isPet or isPet and NekometerConfig.mergePets then
            local owner = pets:Lookup(sourceId)
            if owner then
                sourceId = owner.id
                sourceName = owner.name
            else
                -- unable to determine owner
                sourceId = sourceName
            end
        end
    end
    return nekometer.event:new({
        sourceId = sourceId,
        sourceName = util:RemoveRealmInfo(sourceName),
        destId = event[8],
        destName = event[9],
    })
end

local filterOwned = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MINE,
    COMBATLOG_OBJECT_AFFILIATION_PARTY,
    COMBATLOG_OBJECT_AFFILIATION_RAID,
    COMBATLOG_OBJECT_REACTION_FRIENDLY,
    COMBATLOG_OBJECT_CONTROL_MASK,
    COMBATLOG_OBJECT_TYPE_GUARDIAN,
    COMBATLOG_OBJECT_TYPE_PET,
    COMBATLOG_OBJECT_TYPE_OBJECT
)

function parser:hasOwner(event)
    local sourceFlags = event[6]
    return CombatLog_Object_IsA(sourceFlags, filterOwned)
end

local filterPet = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MINE,
    COMBATLOG_OBJECT_AFFILIATION_PARTY,
    COMBATLOG_OBJECT_AFFILIATION_RAID,
    COMBATLOG_OBJECT_REACTION_FRIENDLY,
    COMBATLOG_OBJECT_CONTROL_PLAYER,
    COMBATLOG_OBJECT_TYPE_PET
)


function parser:isPet(event)
    local sourceFlags = event[6]
    return CombatLog_Object_IsA(sourceFlags, filterPet)
end

nekometer.parser = parser