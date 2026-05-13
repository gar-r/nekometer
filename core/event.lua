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
    elseif self:IsFriendlyAbsorb() then
        -- the absorb event arr has a variable size
        self:calcAbsorbOffsets()
        sourceId = self[#self - self._absorbOffsets.source - 2]
        sourceName = self[#self - self._absorbOffsets.source - 1]
        sourceFlags = self[#self - self._absorbOffsets.source]
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
        -- the absorb event arr has a variable size
        self:calcAbsorbOffsets()
        return self[#self - self._absorbOffsets.amount]
    else
        return 0
    end
end

function event:calcEffectiveAmount(totalIdx, overkillIdx)
    local total = self[totalIdx] or 0
    local overkill = self[overkillIdx] or 0
    if overkill < 0 then
        overkill = 0
    end
    return total - overkill
end

function event:GetAbility()
    local atype = self:GetType()
    local classic = util:IsClassic()
    if atype == swingDamage then
        return { id = classic and 6603 or 260421, name = "Melee" }
    elseif self:IsSpellReflect() then
        return { id = 69901, name = "Spell Reflect" }
    elseif self:IsFriendlyAbsorb() then
        -- the absorb event arr has a variable size
        self:calcAbsorbOffsets()
        return { id = self[#self - self._absorbOffsets.ability - 1], name = self[#self - self._absorbOffsets.ability] }
    else
        return { id = self[12], name = self[13] }
    end
end

function event:IsSourceFriendly()
    return filter:IsFriendly(self[6])
end

function event:IsDamage()
    return string.match(self:GetType(), "_DAMAGE$") ~= nil
end

function event:IsHeal()
    return string.match(self:GetType(), "_HEAL$") ~= nil
end

function event:IsSummon()
    return string.match(self:GetType(), "_SUMMON$") ~= nil
end

-- a special spell effect that damages oneself
function event:IsSelfHarm()
    return self:IsDamage()
        and self[4] == self[8] -- source and dest are the same
end

function event:IsSpellReflect()
    return filter:IsEnemy(self[6])
        and filter:IsFriendly(self[10])
        and not filter:IsOwned(self[10])
        and self:GetType() == spellMissed
        and self[15] == reflect
end

function event:calcAbsorbOffsets()
    -- 5.5.4 tail arg critical seems to be omitted if not boolean true (true/nil instead of true/false)
    -- offset compute becomes dynamic, has to be checked on every event
    self._absorbOffsets = self._absorbOffsets or {
        source = 6,
        amount = 1,
        ability = 3,
    }
    local hasCriticalTail = type(self[#self]) == "boolean"
    self._absorbOffsets.source = hasCriticalTail and 6 or 5
    self._absorbOffsets.amount = hasCriticalTail and 1 or 0
    self._absorbOffsets.ability = hasCriticalTail and 3 or 2
end

function event:IsAbsorb()
    return self:GetType() == spellAbsorb
end

function event:IsFriendlyAbsorb()
    self:calcAbsorbOffsets()
    return self:IsAbsorb()
        and filter:IsFriendly(self[#self - self._absorbOffsets.source]) -- caster (!) flags
end

function event:IsFriendlyDeath()
    return self:GetType() == unitDied
        and filter:IsFriendly(self[10])
end

function event:IsInterrupt()
    return string.match(self:GetType(), "_INTERRUPT$") ~= nil
end

function event:IsDispel()
    return string.match(self:GetType(), "_DISPEL$") ~= nil
        or string.match(self:GetType(), "_STOLEN$") ~= nil
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

function event:IsSourceMissing()
    local source = self:GetSource()
    return not source.id
        or source.id == ""
        or not source.name
        or source.name == ""
end

nekometer.event = event
