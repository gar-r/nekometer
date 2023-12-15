SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local _, nekometer = ...

local function SlashCommandHandler(_, _)
    local damage = nekometer.damage
    if damage then
        for k, v in pairs(damage) do
            print(k .. ": " .. v)
        end
    end
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler