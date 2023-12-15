SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local addonName, nekometer = ...

local function SlashCommandHandler(_, _)
    print(addonName .. " version " .. nekometer.version)
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler