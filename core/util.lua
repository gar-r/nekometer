local _, nekometer = ...

local util = {}

-- Removes the server info from a player name
function util:RemoveRealmInfo(playerName)
    if playerName then
        local idx = string.find(playerName, "-") or 0
        return string.sub(playerName, 1, idx-1)
    end
end

nekometer.util = util