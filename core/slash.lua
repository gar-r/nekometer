SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local _, nekometer = ...

local function SlashCommandHandler(_, _)
    if nekometer.total then
        nekometer.total:PrintAll()
    end
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler