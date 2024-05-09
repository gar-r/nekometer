local _, nekometer = ...

local event = {}

local filter = nekometer.filter
local pets = nekometer.pets
local util = nekometer.util

local playerId = UnitGUID("player")
local swingDamage = "SWING_DAMAGE"
local spellDamage = "SPELL_DAMAGE"
local spellMissed = "SPELL_MISSED"
local reflect = "REFLECT"

function event:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function event:IsSourceFriendly()
    return filter:IsFriendly(self[6])
end

function event:GetType()
    return self[2]
end

function event:IsDamage()
    return string.match(self:GetType(), "_DAMAGE$")
end

function event:IsHeal()
    return string.match(self:GetType(), "_HEAL$")
end

-- gets the amount, which can be located at different indices
-- based on the type of the event
function event:GetAmount()
    if self:GetType() == swingDamage then
        return self[12] or 0
    elseif self:IsDamage() or self:IsHeal() then
        return self[15] or 0
    else
        return 0
    end
end

-- a special spell effect that damages oneself
function event:IsSelfHarm()
    return self:GetType() == spellDamage
        and self[4] == self[8]  -- source and dest are the same
end

function event:IsSpellReflect()
    return filter:IsEnemy(self[6])
        and self:GetType() == spellMissed
        and self[15] == reflect
end

-- swap the source and dest units in the event
function event:SwapActors()
    self:swap(4, 8)     -- id
    self:swap(5, 9)     -- name
    self:swap(6, 10)    -- flags
    self:swap(7, 11)    -- raid flags
end

function event:swap(idx1, idx2)
    local tmp = idx1
    self[idx1] = self[idx2]
    self[idx2] = tmp
end

--[[
    Helper function to get the event's source unit: { id, name }.
    In case the source is a unit with an owner (pet, guardian), and the "mergePets"
    global option is enabled, the owner is returned instead.
]]
function event:GetSource()
    local sourceId = self[4]
    local sourceName = self[5]
    local sourceFlags = self[6]
    if filter:IsOwned(sourceFlags) then
        local isPet = filter:IsPet(sourceFlags)
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
    return {
        id = sourceId,
        name = util:RemoveRealmInfo(sourceName),
    }
end

--[[
    Helper function to get the event's destination unit: {id, name}.
]]
function event:GetDest()
    return {
        id = self[8],
        name = self[9],
    }
end

function event:IsDoneByPlayer()
    local sourceId = self[4]
    if sourceId and sourceId == playerId then
        return true
    end
    -- also attribute the player's pet to the player,
    -- regardless of the mergePets config setting
    local owner = pets:Lookup(sourceId)
    return owner and owner.id == playerId
end

nekometer.event = event
