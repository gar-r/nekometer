local _, nekometer = ...

--[[
    Dispatcher is a "meter-visitor", with filtering.
    Only events that are relevant to the player/party/raid
    are forwarded to the meters.
]]
local dispatcher = {
	meters = {},
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
	local e = nil
	if parser:isSpellReflect(event) and self.previousSelfHarm then
		e = parser:ParseReflect(event, self.previousSelfHarm)
        self.previousSelfHarm = nil
	elseif parser:isRelevant(event) then
		e = parser:Parse(event)
	end
	if e then
		self:notifyMeters("Accept", e)
	end
    if parser:isSelfHarm(event) then
        self.previousSelfHarm = event
    end
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
