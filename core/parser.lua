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

function parser:ParseReflect(event, prevSelfHarm)
    -- This is a reflect event, so source and dest entities are swapped.
    -- We also need to use the preceding self-harm event to determine the damage.
    return nekometer.event:new({
        sourceId = event[8],
        sourceName = event[9],
        destId = event[4],
        destName = event[5],
        ability = "Spell Reflect",
        amount = prevSelfHarm[15] or 0,
        type = nekometer.EVENT_TYPE_DAMAGE,
    })
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

local filterRelevant = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MINE,
    COMBATLOG_OBJECT_AFFILIATION_PARTY,
    COMBATLOG_OBJECT_AFFILIATION_RAID,
    COMBATLOG_OBJECT_REACTION_FRIENDLY,
    COMBATLOG_OBJECT_CONTROL_MASK,
    COMBATLOG_OBJECT_TYPE_MASK
)

function parser:isRelevant(event)
    local sourceFlags = event[6]
	return CombatLog_Object_IsA(sourceFlags, filterRelevant)
end

function parser:isSelfHarm(event)
    return event[2] == "SPELL_DAMAGE" and event[4] == event[8]
end

local filterEnemy = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
    COMBATLOG_OBJECT_REACTION_NEUTRAL,
    COMBATLOG_OBJECT_REACTION_HOSTILE,
    COMBATLOG_OBJECT_CONTROL_MASK,
    COMBATLOG_OBJECT_TYPE_MASK
)

function parser:isSpellReflect(event)
    local sourceFlags = event[6]
    return CombatLog_Object_IsA(sourceFlags, filterEnemy) and
        event[2] == "SPELL_MISSED" and
        event[15] == "REFLECT"
end

nekometer.parser = parser
