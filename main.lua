local addonName, nekometer = ...

local config = nekometer.config
local parser = nekometer.parser

---@class Frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        config:Init()
        -- parser:AddMeter(nekometer.printer)
        parser:AddMeter(nekometer.total)
        parser:AddMeter(nekometer.dps)
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    parser:HandleCombatEvent()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", frame.OnEvent)
