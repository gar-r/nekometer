local _, nekometer = ...

local commands = nekometer.commands

function OnAddonCompartmentClick()
    commands:toggle()
end