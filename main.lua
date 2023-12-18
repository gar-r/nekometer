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
        dispatcher:AddMeter(nekometer.printer)
        dispatcher:AddMeter(nekometer.damage)
        dispatcher:AddMeter(nekometer.dps)
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    dispatcher:HandleCombatEvent()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", frame.OnEvent)
