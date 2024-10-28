local lu = require("luaunit")

local commandsMock = {}
local nekometer = {
    commands = commandsMock,
}

loadfile("core/autoreset.lua")("test", nekometer)

TestAutoReset = {}

function TestAutoReset:setUp()
    commandsMock:resetMock()
end

function TestAutoReset:test_auto_reset_with_confirmation_on_enter_instance()
    NekometerConfig = {
        autoResetOnEnterInstance = true,
        autoResetConfirmation = true,
    }
    IsInInstance = function() return true end
    nekometer.autoreset:HandleZoneChange()
    lu.assertTrue(commandsMock.resetWithConfirmationCalled)
end

function TestAutoReset:test_auto_reset_without_confirmation_on_enter_instance()
    NekometerConfig = {
        autoResetOnEnterInstance = true,
        autoResetConfirmation = false,
    }
    IsInInstance = function() return true end
    nekometer.autoreset:HandleZoneChange()
    lu.assertTrue(commandsMock.resetCalled)
end

function TestAutoReset:test_auto_reset_with_confirmation_on_enter_delve()
    NekometerConfig = {
        autoResetOnEnterDelve = true,
        autoResetConfirmation = true,
    }
    UnitPosition = function(_) return 0, 0, 0, 0 end
    C_DelvesUI = {
        HasActiveDelve = function(_) return true end
    }
    nekometer.autoreset:HandleDelveUpdate()
    lu.assertTrue(commandsMock.resetWithConfirmationCalled)
end

function TestAutoReset:test_auto_reset_without_confirmation_on_enter_delve()
    NekometerConfig = {
        autoResetOnEnterDelve = true,
        autoResetConfirmation = false,
    }
    UnitPosition = function(_) return 0, 0, 0, 0 end
    C_DelvesUI = {
        HasActiveDelve = function(_) return true end
    }
    nekometer.autoreset:HandleDelveUpdate()
    lu.assertTrue(commandsMock.resetCalled)
end

function commandsMock:resetWithConfirmation()
    self.resetWithConfirmationCalled = true
end

function commandsMock:reset()
    self.resetCalled = true
end

function commandsMock:resetMock()
    self.resetWithConfirmationCalled = false
    self.resetCalled = false
end