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
            nekometer.dps,
        }
        for _, meter in ipairs(nekometer.enabledMeters) do
            dispatcher:AddMeter(meter)
        end
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    dispatcher:HandleCombatEvent()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", frame.OnEvent)
