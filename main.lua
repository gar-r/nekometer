local addonName, nekometer = ...

local config = nekometer.config
local dispatcher = nekometer.dispatcher

---@class Frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        config:Init()
        -- TODO: get from config
        nekometer.enabledMeters = {
            nekometer.damage,
            nekometer.dps_current,
            nekometer.dps_combat,
            nekometer.healing,
        }
        for _, meter in ipairs(nekometer.enabledMeters) do
            dispatcher:AddMeter(meter)
        end
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    dispatcher:HandleCombatEvent()
end

function frame:PLAYER_REGEN_DISABLED()
    dispatcher:CombatEntered()
end

function frame:PLAYER_REGEN_ENABLED()
    dispatcher:CombatExited()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", frame.OnEvent)
