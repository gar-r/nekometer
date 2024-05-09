local _, nekometer = ...

--[[
    Dispatcher is a "meter-visitor", with filtering.
    Only events that are relevant to the player/party/raid
    are forwarded to the meters.
]]
local dispatcher = {
	meters = {},
	prevSelfHarm = 0,
}

local event = nekometer.event

function dispatcher:AddMeter(meter, cfg)
	if meter.Init then
		meter:Init(cfg)
	end
	table.insert(self.meters, meter)
end

function dispatcher:HandleCombatEvent()
	local raw = { CombatLogGetCurrentEventInfo() }
	local e = event:new(raw)
	if e:IsSourceFriendly() then
		self:notifyMeters("CombatEvent", e)
	else
		self:handleIfSpellReflect(e)
		self:recordSelfHarm(e)
	end

end

function dispatcher:HandleCombatEntered()
	self:notifyMeters("CombatEntered")
end

function dispatcher:HandleCombatExited()
	self:notifyMeters("CombatExited")
end

function dispatcher:handleIfSpellReflect(e)
	if e:IsSpellReflect() then
		e:SwapActors()
		e[15] = self.prevSelfHarm
		self:notifyMeters("CombatEvent", e)
	end
end

function dispatcher:recordSelfHarm(e)
	if e:IsSelfHarm() then
		self.prevSelfHarm = 0
	end
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
