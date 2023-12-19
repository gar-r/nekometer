local _, nekometer = ...

local mainFrame = nekometer.frames.main

local resetDialog = {
    text = "Reset Nekometer data?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function ()
        mainFrame:ResetCurrentMeter()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["NEKOMETER_RESET"] = resetDialog