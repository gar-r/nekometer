local _, nekometer = ...

--[[
    Dispatcher is a "meter-visitor", with filtering.
    Only events that are relevant to the player/party/raid
    are forwarded to the meters.
]]
local dispatcher = {
    meters = {}
}

local parser = nekometer.parser

function dispatcher:AddMeter(meter)
    if meter.Init then
        meter:Init(NekometerConfig)
    end
    table.insert(self.meters, meter)
end

function dispatcher:HandleCombatEvent()
    local event = { CombatLogGetCurrentEventInfo() }
    if self:isRelevant(event) then
        local e = parser:Parse(event)
        if e then
            self:notifyMeters("Accept", e)
        end
    end
end

function dispatcher:isRelevant(event)
    local sourceFlags = event[6]
    local relevant = bit.bor(
        COMBATLOG_FILTER_ME,
        COMBATLOG_FILTER_MY_PET
    )
    return CombatLog_Object_IsA(sourceFlags, relevant)
end

function dispatcher:CombatEntered()
    self:notifyMeters("CombatEntered")
end

function dispatcher:CombatExited()
    self:notifyMeters("CombatExited")
end

function dispatcher:notifyMeters(fname, e)
    for _, meter in ipairs(self.meters) do
        local fn = meter[fname]
        if fn then
            fn(meter, e)
        end
    end
end


nekometer.dispatcher = dispatcher
