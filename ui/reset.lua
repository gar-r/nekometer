local _, _ = ...

local resetDialog = {
    text = "Reset Nekometer data?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function () end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["NEKOMETER_RESET"] = resetDialog