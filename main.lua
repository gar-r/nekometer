local addonName, nekometer = ...

---@class frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        nekometer.version = C_AddOns.GetAddOnMetadata(addonName, "Version")
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    nekometer:RecordCombatLogEvent()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", frame.OnEvent)
