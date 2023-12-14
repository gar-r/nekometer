local addonName, ns = ...

---@class frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        ns.version = C_AddOns.GetAddOnMetadata(name, "Version")
        print(addonName .. " version " .. ns.version .. " loaded")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", frame.OnEvent)