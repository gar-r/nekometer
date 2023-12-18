local _, nekometer = ...

local event = {}

local eventTypeDamage = "damage"
local eventTypeHeal = "heal"

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

nekometer.EVENT_TYPE_DAMAGE = eventTypeDamage
nekometer.EVENT_TYPE_HEAL = eventTypeHeal

nekometer.event = event
