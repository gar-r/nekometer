SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local _, nekometer = ...

local function SlashCommandHandler(msg, _)
    if msg == "config" then
        InterfaceOptionsFrame_OpenToCategory(nekometer.frames.config)
    elseif msg == "reset" then
        StaticPopup_Show("NEKOMETER_RESET")
    end
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler