local lu = require("luaunit")

local mockClassIcons = {}

local nekometer = {
    classIcons = mockClassIcons,
}

loadfile("core/specs.lua")("test", nekometer)

GetSpecializationInfoByID = function(_)
    return "specId", "specName", "specDesc", "specIcon"
end

GetNumGroupMembers = function(_)
    return 20
end

IsInRaid = function()
    return false
end

local notifyCalled = false
local notifyArg = nil
NotifyInspect = function(arg)
    notifyCalled = true
    notifyArg = arg
end

TestSpecs = {}

function TestSpecs:setUp()
    mockClassIcons:resetMock()
    nekometer.specs.inProgress = {}
    notifyCalled = false
    notifyArg = nil
end

function TestSpecs:test_handle_inspect_ready_not_in_progress()
    nekometer.specs.inProgress = {}
    nekometer.specs:HandleInspectReady("id")
    lu.assertFalse(mockClassIcons.setCalled)
end

function TestSpecs:test_handle_inspect_ready_no_spec()
    nekometer.specs.inProgress = { unitId = "party3" }
    GetInspectSpecialization = function(_)
        return 0
    end
    nekometer.specs:HandleInspectReady("unitId")
    self:verifyNotInprogress("unitId")
    lu.assertFalse(mockClassIcons.setCalled)
end

function TestSpecs:test_handle_inspect_ready_spec_icon_cached()
    nekometer.specs.inProgress = { unitId = "party3" }
    GetInspectSpecialization = function(_)
        return 1
    end
    nekometer.specs:HandleInspectReady("unitId")
    self:verifyNotInprogress("unitId")
    lu.assertTrue(mockClassIcons.setCalled)
    lu.assertEquals(mockClassIcons.setArgs, { "unitId", "specIcon" })
end

function TestSpecs:test_get_specialization_by_id_unit_not_found()
    UnitGUID = function(_) end
    nekometer.specs:GetSpecializationByID("id")
    self:verifyNotInprogress("id")
    lu.assertFalse(notifyCalled)
end

function TestSpecs:test_get_specialization_by_id_unit_not_inspectable()
    UnitGUID = function(_)
        return "id"
    end
    CanInspect = function(_)
        return false
    end
    nekometer.specs:GetSpecializationByID("id")
    self:verifyNotInprogress("id")
    lu.assertFalse(notifyCalled)
end

function TestSpecs:test_get_specialization_by_id_already_in_progress()
    UnitGUID = function(_)
        return "id"
    end
    CanInspect = function(_)
        return true
    end
    nekometer.specs.inProgress = { id = "unitId" }
    nekometer.specs:GetSpecializationByID("id")
    lu.assertFalse(notifyCalled)
end

function TestSpecs:test_get_specialization_by_id_notify_called()
    UnitGUID = function(unit)
        if unit == "party5" then
            return "id"
        end
    end
    CanInspect = function(_)
        return true
    end
    nekometer.specs:GetSpecializationByID("id")
    lu.assertTrue(notifyCalled)
    lu.assertEquals(notifyArg, "party5")
    lu.assertEquals(nekometer.specs.inProgress.id, "party5")
end

function TestSpecs:verifyNotInprogress(unit)
    lu.assertEquals(nekometer.specs.inProgress[unit], nil)
end

function mockClassIcons:Set(id, icon)
    self.setCalled = true
    self.setArgs = { id, icon }
end

function mockClassIcons:resetMock()
    self.setCalled = false
    self.setArgs = nil
end
