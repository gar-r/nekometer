local _, nekometer = ...

local event = {}

local filter = nekometer.filter
local pets = nekometer.pets
local util = nekometer.util

local playerId = UnitGUID("player")
local swingDamage = "SWING_DAMAGE"
local spellDamage = "SPELL_DAMAGE"
local spellMissed = "SPELL_MISSED"
local spellAbsorb = "SPELL_ABSORBED"
local reflect = "REFLECT"
local unitDied = "UNIT_DIED"

function event:new(o, prevSelfHarm)
    o = o or {}
    o.prevSelfHarm = prevSelfHarm
    setmetatable(o, self)
    self.__index = self
    return o
end

function event:GetType()
    return self[2]
end

--[[
    Helper function to get the event's source unit: { id, name }.
    In case the source is a unit with an owner (pet, guardian), and the "mergePets"
    global option is enabled, the owner is returned instead.
]]
function event:GetSource()
    local sourceId
    local sourceName
    local sourceFlags
    if self:IsSpellReflect() then
        sourceId = self[8]
        sourceName = self[9]
        sourceFlags = self[10]
    elseif self:IsAbsorb() then
        -- the absorb event arr has a variable size, but the source
        -- will always be at position len-8..len-6
        sourceId = self[#self - 8]
        sourceName = self[#self - 7]
        sourceFlags = self[#self - 6]
    else
        sourceId = self[4]
        sourceName = self[5]
        sourceFlags = self[6]
    end
    if filter:IsOwned(sourceFlags) then
        local isPet = filter:IsPet(sourceFlags)
        if not isPet or isPet and NekometerConfig.mergePets then
            local owner = pets:Lookup(sourceId)
            if owner then
                sourceId = owner.id
                sourceName = owner.name
            end
        end
    end
    return {
        id = sourceId,
        name = util:RemoveRealmInfo(sourceName),
    }
end

-- Gets the amount encapsulated in the event, adjusted with overkill,  overheal, etc.
function event:GetAmount()
    if self:IsSpellReflect() then
        return self.prevSelfHarm or 0
    elseif self:GetType() == swingDamage then
        return self:calcEffectiveAmount(12, 13)
    elseif self:IsDamage() or self:IsHeal() then
        return self:calcEffectiveAmount(15, 16)
    elseif self:IsAbsorb() then
        -- the absorb event arr has a variable size, but the amount
        -- will always be at position len-1
        return self[#self - 1]
    else
        return 0
    end
end

function event:calcEffectiveAmount(totalIdx, overkillIdx)
    local total = self[totalIdx] or 0
    local overkill = self[overkillIdx] or 0
    return total - overkill
end

function event:GetAbilityName()
    local type = self:GetType()
    if type == swingDamage then
        return "Melee"
    elseif self:IsSpellReflect() then
        return "Spell Reflect"
    elseif self:IsAbsorb() then
        -- the absorb event arr has a variable size, but the spell name
        -- will always be at position len-3
        return self[#self - 3]
    else
        return self[13]
    end
end

function event:IsSourceFriendly()
    return filter:IsFriendly(self[6])
end

function event:IsDamage()
    return string.match(self:GetType(), "_DAMAGE$")
end

function event:IsHeal()
    return string.match(self:GetType(), "_HEAL$")
end

-- a special spell effect that damages oneself
function event:IsSelfHarm()
    return self[4] == self[8] -- source and dest are the same
end

function event:IsSpellReflect()
    return filter:IsEnemy(self[6])
        and filter:IsFriendly(self[10])
        and not filter:IsOwned(self[10])
        and self:GetType() == spellMissed
        and self[15] == reflect
end

function event:IsAbsorb()
    return self:GetType() == spellAbsorb
        and filter:IsFriendly(self[#self - 6]) -- caster (!) flags
end

function event:IsFriendlyDeath()
    return self:GetType() == unitDied
        and filter:IsFriendly(self[10])
end

function event:IsInterrupt()
    return string.match(self:GetType(), "_INTERRUPT$")
end

function event:IsDispel()
    return string.match(self:GetType(), "_DISPEL$")
        or string.match(self:GetType(), "_STOLEN$")
end

function event:IsDoneByPlayer()
    local source = self:GetSource()
    if source.id and source.id == playerId then
        return true
    end
    -- also attribute the player's pet to the player,
    -- even when the mergePets option is disabled
    if not NekometerConfig.mergePets then
        local owner = pets:Lookup(source.id)
        return owner and owner.id == playerId
    end
    return false
end

nekometer.event = event
