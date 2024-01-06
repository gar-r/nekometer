local _, nekometer = ...

local event = {}

local eventTypeDamage = "damage"
local eventTypeHeal = "heal"

local pets = nekometer.pets
local playerId = UnitGUID("player")

function event:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function event:isDamage()
    return self.type == eventTypeDamage
end

function event:isHeal()
    return self.type == eventTypeHeal
end

function event:isDoneByPlayer()
    if self.sourceId then
        if self.sourceId == playerId then
            return true
        end
        local owner = pets:Lookup(self.sourceId)
        return owner and owner.id == playerId
    end
    return false
end

nekometer.EVENT_TYPE_DAMAGE = eventTypeDamage
nekometer.EVENT_TYPE_HEAL = eventTypeHeal

nekometer.event = event
