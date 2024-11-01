local lu = require("luaunit")

local mockClassIcons = {}

local nekometer = {
    classIcons = mockClassIcons,
}

loadfile("core/specs.lua")("test", nekometer)

local specs = nekometer.specs

TestSpecs = {
    notifyCalled = false,
    notifyArg = nil,
}

function TestSpecs:setUp()
    mockClassIcons:resetMock()
    specs.pendingInspect = {}
    specs.inProgress = nil
    self.notifyCalled = false
    self.notifyArg = nil
    self.clearCalled = false
    UnitGUID = function(unitId)
        return unitId .. "-id"
    end
    NotifyInspect = function(arg)
        self.notifyCalled = true
        self.notifyArg = arg
    end
    ClearInspectPlayer = function()
        self.clearCalled = true
    end
    GetInspectSpecialization = function(_)
        return 1
    end
    GetSpecializationInfoByID = function(_)
        return "specId", "specName", "specDesc", "specIcon"
    end
    GetNumGroupMembers = function(_)
        return 20
    end
    IsInRaid = function()
        return false
    end
    C_Timer = {
        After = function(_, _) end
    }
end

function TestSpecs:test_get_specialization_by_id_while_lookup_in_progress()
    specs.inProgress = { id = "id", unit = "unit" }
    specs:GetSpecializationByID("party4-id")
    lu.assertFalse(self.notifyCalled)
    lu.assertEquals(specs.inProgress, { id = "id", unit = "unit" })
    lu.assertEquals(specs.pendingInspect, {
        { id = "party4-id", unit = "party4" },
        ["party4-id"] = "party4"
    })
end

function TestSpecs:test_get_specialization_by_id()
    specs:GetSpecializationByID("party4-id")
    lu.assertEquals(specs.inProgress, { id = "party4-id", unit = "party4" })
    lu.assertEquals(specs.pendingInspect, {})
    lu.assertTrue(self.notifyCalled)
    lu.assertEquals(self.notifyArg, "party4")
end

function TestSpecs:test_get_specialization_by_id_pending()
    specs:GetSpecializationByID("party4-id")
    specs:GetSpecializationByID("party1-id")
    specs:GetSpecializationByID("party2-id")
    lu.assertEquals(specs.inProgress, { id = "party4-id", unit = "party4" })
    lu.assertEquals(specs.pendingInspect, {
        { id = "party1-id", unit = "party1" },
        { id = "party2-id", unit = "party2" },
        ["party1-id"] = "party1",
        ["party2-id"] = "party2",
    })
    lu.assertTrue(self.notifyCalled)
    lu.assertEquals(self.notifyArg, "party4")
end

function TestSpecs:test_inspect_next()
    specs.pendingInspect = {
        { id = "party1-id", unit = "party1" },
        { id = "party2-id", unit = "party2" },
    }
    specs:InspectNext()
    lu.assertEquals(specs.inProgress, { id = "party2-id", unit = "party2" })
    lu.assertEquals(specs.pendingInspect, {
        { id = "party1-id", unit = "party1" },
    })
    lu.assertTrue(self.notifyCalled)
    lu.assertEquals(self.notifyArg, "party2")
end

function TestSpecs:test_inspect_next_no_pending()
    specs:InspectNext()
    lu.assertEquals(specs.inProgress, nil)
    lu.assertEquals(specs.pendingInspect, {})
    lu.assertFalse(self.notifyCalled)
end

function TestSpecs:test_inspect_next_timeout()
    specs.pendingInspect = {
        { id = "party1-id", unit = "party1" },
        { id = "party2-id", unit = "party2" },
    }
    -- simulate the inspect taking longer than 3 seconds for the first call
    local firstCall = true
    C_Timer = {
        After = function(_, cb)
            if firstCall then
                firstCall = false
                cb()
                return
            end
        end
    }
    specs:InspectNext()
    lu.assertEquals(specs.inProgress, { id = "party1-id", unit = "party1" })
    lu.assertEquals(specs.pendingInspect, {})
end

function TestSpecs:test_handle_inspect_ready()
    specs.inProgress = { id = "party1-id", unit = "party1" }
    specs:HandleInspectReady("party1-id")
    lu.assertEquals(specs.inProgress, nil)
    lu.assertTrue(self.clearCalled)
    lu.assertTrue(mockClassIcons.setCalled)
    lu.assertEquals(mockClassIcons.setArgs, { "party1-id", "specIcon" })
end

function TestSpecs:test_handle_inspect_ready_different_unit()
    specs.inProgress = { id = "party1-id", unit = "party1" }
    specs:HandleInspectReady("party2-id")
    lu.assertEquals(specs.inProgress, { id = "party1-id", unit = "party1" })
    lu.assertFalse(self.clearCalled)
    lu.assertFalse(mockClassIcons.setCalled)
end

function mockClassIcons:Set(id, icon)
    self.setCalled = true
    self.setArgs = { id, icon }
end

function mockClassIcons:resetMock()
    self.setCalled = false
    self.setArgs = nil
end
