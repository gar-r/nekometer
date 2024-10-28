local lu = require("luaunit")

local commandsMock = {}
local timerMock = {}
C_Timer = {
    After = function (delay, fn)
        timerMock:After(delay, fn)
    end
}

local nekometer = {
    commands = commandsMock,
}

loadfile("core/autohide.lua")("test", nekometer)

TestAutoHide = {}

function TestAutoHide:setUp()
    commandsMock:resetMock()
    timerMock:resetMock()
    nekometer.autohide.cancelTimer = false
end

function TestAutoHide:test_handle_combat_entered_window_shown()
    NekometerConfig = { windowShown = true }
    nekometer.autohide:HandleCombatEntered()
    lu.assertTrue(commandsMock.showCalled)
    lu.assertEquals(commandsMock.showCalledArgs, { true })
    lu.assertTrue(nekometer.autohide.cancelTimer)
end

function TestAutoHide:test_handle_combat_entered_window_hidden()
    NekometerConfig = { windowShown = false }
    nekometer.autohide:HandleCombatEntered()
    lu.assertFalse(commandsMock.showCalled)
    lu.assertTrue(nekometer.autohide.cancelTimer, true)
end

function TestAutoHide:test_handle_combat_exited_window_shown()
    NekometerConfig = {
        autoHide = true,
        autoHideDelay = 5,
        windowShown = true,
    }
    nekometer.autohide:HandleCombatExited()
    lu.assertEquals(timerMock.delay, NekometerConfig.autoHideDelay)
    lu.assertTrue(commandsMock.showCalled)
    lu.assertEquals(commandsMock.showCalledArgs, { false })
end

function TestAutoHide:test_handle_combat_exited_window_hidden()
    NekometerConfig = {
        autoHide = true,
        windowShown = false,
    }
    nekometer.autohide:HandleCombatExited()
    lu.assertEquals(timerMock.delay, NekometerConfig.autoHideDelay)
    lu.assertFalse(commandsMock.showCalled)
end

function TestAutoHide:test_handle_combat_exited_combat_reentered()
    NekometerConfig = {
        autoHide = true,
        windowShown = true,
    }
    timerMock.beforeFn = function ()
        nekometer.autohide.cancelTimer = true
    end
    nekometer.autohide:HandleCombatExited()
    lu.assertFalse(commandsMock.showCalled)
    lu.assertFalse(nekometer.autohide.cancelTimer)
end

function TestAutoHide:test_should_hide_when_auto_hide_disabled_in_instances()
    NekometerConfig = {
        autoHide = true,
        autoHideDisabledInInstances = true,
    }
    IsInInstance = function ()
        return true, nil
    end
    lu.assertFalse(nekometer.autohide:shouldHide())
end

function TestAutoHide:test_should_hide_when_auto_hide_disabled_in_groups()
    NekometerConfig = {
        autoHide = true,
        autoHideDisabledInGroups = true,
    }
    IsInGroup = function ()
        return true, nil
    end
    lu.assertFalse(nekometer.autohide:shouldHide())
end


function commandsMock:show(shown)
    self.showCalled = true
    self.showCalledArgs = { shown }
end

function commandsMock:resetMock()
    self.showCalled = false
    self.showCalledArgs = {}
end

function timerMock:After(delay, fn)
    self.delay = delay
    if self.beforeFn then
        self.beforeFn()
    end
    fn()
end

function timerMock:resetMock()
    self.delay = nil
    self.beforeFn = nil
end
