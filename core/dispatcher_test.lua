local lu = require("luaunit")

local mockEvent = {}
local mockPets = {}
local nekometer = {
    event = mockEvent,
    pets = mockPets,
}


loadfile("core/dispatcher.lua")("test", nekometer)

TestDispatcher = {}

function TestDispatcher:setUp()
    CombatLogGetCurrentEventInfo = function() end
    mockEvent:resetMock()
end

function TestDispatcher:test_add_meter()
    local initCalled = false
    local meter = {
        Init = function()
            initCalled = true
        end
    }
    nekometer.dispatcher:AddMeter(meter)
    lu.assertEquals(nekometer.dispatcher.meters[1], meter)
    lu.assertTrue(initCalled)
end

function TestDispatcher:test_dispatch_combat_entered_event()
    self:verifyEventDispatched("CombatEntered", function()
        nekometer.dispatcher:HandleCombatEntered()
    end)
end

function TestDispatcher:test_dispatch_combat_exited_event()
    self:verifyEventDispatched("CombatExited", function()
        nekometer.dispatcher:HandleCombatExited()
    end)
end

function TestDispatcher:test_dispatch_combat_event_friendly_unit()
    mockEvent.isSourceFriendly = true
    self:verifyEventDispatched("CombatEvent", function()
        nekometer.dispatcher:HandleCombatEvent()
    end)
end

function TestDispatcher:test_prev_self_harm_cleared_on_dispatch()
    mockEvent.isSourceFriendly = true
    nekometer.dispatcher.prevSelfHarm = 100
    nekometer.dispatcher:HandleCombatEvent()
    lu.assertEquals(nekometer.dispatcher.prevSelfHarm, 0)
end

function TestDispatcher:test_dispatch_combat_event_absorb()
    mockEvent.isAbsorb = true
    self:verifyEventDispatched("CombatEvent", function()
        nekometer.dispatcher:HandleCombatEvent()
    end)
end

function TestDispatcher:test_dispatch_combat_event_spell_reflect()
    mockEvent.isSpellReflect = true
    self:verifyEventDispatched("CombatEvent", function()
        nekometer.dispatcher:HandleCombatEvent()
    end)
end

function TestDispatcher:test_dispatch_combat_event_friendly_death()
    mockEvent.isFriendlyDeath = true
    self:verifyEventDispatched("CombatEvent", function()
        nekometer.dispatcher:HandleCombatEvent()
    end)
end

function TestDispatcher:test_dispatch_skipped_if_source_missing()
    mockEvent.isSourceMissing = true
    self:verifyEventDispatched("CombatEvent", function()
        nekometer.dispatcher:HandleCombatEvent()
    end, false)
end

function TestDispatcher:test_register_self_harm_event()
    mockEvent.isSelfHarm = true
    mockEvent[15] = 100
    nekometer.dispatcher:HandleCombatEvent()
    lu.assertEquals(nekometer.dispatcher.prevSelfHarm, 100)
end

function TestDispatcher:test_register_summon_event()
    mockEvent.isSummon = true
    mockEvent[8] = "pet"
    mockEvent.GetSource = function()
        return "owner"
    end
    mockPets.Set = function(_, key, value)
        mockPets[key] = value
    end
    nekometer.dispatcher:HandleCombatEvent()
    lu.assertEquals(mockPets["pet"], "owner")
end

function TestDispatcher:verifyEventDispatched(event, action, expected)
    local dispatched = false
    local meter = {
        [event] = function()
            dispatched = true
        end
    }
    nekometer.dispatcher:AddMeter(meter)
    action()
    if expected == nil then
        expected = true
    end
    lu.assertEquals(dispatched, expected)
end

function mockEvent:new()
    return self
end

function mockEvent:IsSelfHarm()
    return self.isSelfHarm
end

function mockEvent:IsSummon()
    return self.isSummon
end

function mockEvent:IsSourceFriendly()
    return self.isSourceFriendly
end

function mockEvent:IsAbsorb()
    return self.isAbsorb
end

function mockEvent:IsSpellReflect()
    return self.isSpellReflect
end

function mockEvent:IsFriendlyDeath()
    return self.isFriendlyDeath
end

function mockEvent:IsSourceMissing()
    return self.isSourceMissing
end

function mockEvent:resetMock()
    self.isSelfHarm = false
    self.isSummon = false
    self.isSourceFriendly = false
    self.isAbsorb = false
    self.isSpellReflect = false
    self.isFriendlyDeath = false
    self.isSourceMissing = false
end