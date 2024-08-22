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
local pets = nekometer.pets

function dispatcher:AddMeter(meter, cfg)
	if meter.Init then
		meter:Init(cfg)
	end
	table.insert(self.meters, meter)
end

function dispatcher:HandleCombatEvent()
	local raw = { CombatLogGetCurrentEventInfo() }
	local e = event:new(raw, self.prevSelfHarm)
	if e:IsSelfHarm() then
		-- self harm events are not dispatched, but we store the damage
		-- in order to be able to track special effects, like spell reflect
		self.prevSelfHarm = e[15]
	elseif e:IsSummon() then
		-- summon events are not dispatched, but we cache the owner details
		pets:Set(e[8], e:GetSource())
	elseif self:shouldDispatch(e) then
		self:notifyMeters("CombatEvent", e)
		self.prevSelfHarm = 0
	end
end

function dispatcher:shouldDispatch(e)
	return e:IsSourceFriendly()
		-- special cases, for which we cannot use the typical source flags (e[6])
		or e:IsAbsorb()
		or e:IsSpellReflect()
		or e:IsFriendlyDeath()
end

function dispatcher:HandleCombatEntered()
	self:notifyMeters("CombatEntered")
end

function dispatcher:HandleCombatExited()
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
