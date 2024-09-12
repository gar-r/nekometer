local _, nekometer = ...

local commands = nekometer.commands

function Nekometer_OnAddonCompartmentClick()
    commands:toggle()
end