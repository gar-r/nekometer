local _, nekometer = ...

local util = {}

-- Removes the server info from a player name
function util:RemoveRealmInfo(playerName)
    if playerName then
        local idx = string.find(playerName, "-") or 0
        return string.sub(playerName, 1, idx - 1)
    end
end

function util:GetSpellTexture(id)
    local info = C_Spell.GetSpellInfo(id)
    if info then
        return info.iconID
    end
end

local baseClassIcons = {
    ["DEATHKNIGHT"] = "Interface/Icons/ClassIcon_DeathKnight",
    ["DEMONHUNTER"] = "Interface/Icons/ClassIcon_DemonHunter",
    ["DRUID"] = "Interface/Icons/ClassIcon_Druid",
    ["EVOKER"] = "Interface/Icons/ClassIcon_Evoker",
    ["HUNTER"] = "Interface/Icons/ClassIcon_Hunter",
    ["MAGE"] = "Interface/Icons/ClassIcon_Mage",
    ["MONK"] = "Interface/Icons/ClassIcon_Monk",
    ["PALADIN"] = "Interface/Icons/ClassIcon_Paladin",
    ["PRIEST"] = "Interface/Icons/ClassIcon_Priest",
    ["ROGUE"] = "Interface/Icons/ClassIcon_Rogue",
    ["SHAMAN"] = "Interface/Icons/ClassIcon_Shaman",
    ["WARLOCK"] = "Interface/Icons/ClassIcon_Warlock",
    ["WARRIOR"] = "Interface/Icons/ClassIcon_Warrior",
}

function util:GetClassTexture(className)
    return baseClassIcons[className]
end

function util:IsClassic()
    return WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE, WOW_PROJECT_ID
end

function util:GetClassColor(class)
    if C_ClassColor and C_ClassColor.GetClassColor then
        return C_ClassColor.GetClassColor(class)
    elseif _G.RAID_CLASS_COLORS then
        local UNKNOWN_COLOR = CreateColor(.75,.75,.75,1)
        return (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class] or UNKNOWN_COLOR
    end
end

function util:ActionButton_ShowOverlayGlow(frame)
    if _G.ActionButton_ShowOverlayGlow then
        return _G.ActionButton_ShowOverlayGlow(frame)
    elseif ActionButtonSpellAlertManager and ActionButtonSpellAlertManager.ShowAlert then
        return ActionButtonSpellAlertManager:ShowAlert(frame)
    end
end
function util:ActionButton_HideOverlayGlow(frame)
    if _G.ActionButton_HideOverlayGlow then
        return _G.ActionButton_HideOverlayGlow(frame)
    elseif ActionButtonSpellAlertManager and ActionButtonSpellAlertManager.HideAlert then
        return ActionButtonSpellAlertManager:HideAlert(frame)
    end
end

nekometer.util = util
