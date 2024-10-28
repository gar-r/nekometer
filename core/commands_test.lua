local lu = require("luaunit")

local nekometer = {}
SlashCmdList = {}

loadfile("core/commands.lua")("test", nekometer)

TestCommands = {}

function TestCommands:setUp()
    self.setShownCalled = false
    self.setShownValue = nil
    nekometer.frames = {
        main = {
            SetShown = function(_, arg)
                self.setShownCalled = true
                self.setShownValue = arg
            end
        }
    }
end

function TestCommands:test_toggle_show()
    NekometerConfig = {
        windowShown = false
    }
    nekometer.commands:toggle()
    lu.assertTrue(self.setShownCalled)
    lu.assertTrue(self.setShownValue)
    lu.assertTrue(NekometerConfig.windowShown)
end

function TestCommands:test_toggle_hide()
    NekometerConfig = {
        windowShown = true
    }
    nekometer.commands:toggle()
    lu.assertTrue(self.setShownCalled)
    lu.assertFalse(self.setShownValue)
    lu.assertFalse(NekometerConfig.windowShown)
end