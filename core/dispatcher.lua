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
            self:notifyMeters(e)
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

function dispatcher:notifyMeters(e)
    for _, meter in ipairs(self.meters) do
        meter:Accept(e)
    end
end


nekometer.dispatcher = dispatcher
