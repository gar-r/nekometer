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

function dispatcher:AddMeter(meter, cfg)
    if meter.Init then
        meter:Init(cfg)
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
        COMBATLOG_OBJECT_AFFILIATION_MINE,
        COMBATLOG_OBJECT_AFFILIATION_PARTY,
		COMBATLOG_OBJECT_AFFILIATION_RAID,
        COMBATLOG_OBJECT_REACTION_FRIENDLY,
		COMBATLOG_OBJECT_CONTROL_MASK,
        COMBATLOG_OBJECT_TYPE_MASK
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
