local _, nekometer = ...

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", "NekometerMainFrame", UIParent, "BackdropTemplate")
frame:SetPoint("CENTER")
frame:SetSize(200, 120)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
})
frame:SetBackdropColor(0, 0, 0, 0.3)
frame:EnableMouse(true)
frame:SetMovable(true)

function frame:Update()
    if nekometer.enabledMeters then
        local meter = self.selectedMeter or nekometer.enabledMeters[1]
        local bars = nekometer.frames.bars
        bars:Display(meter:Report())
    end
end

frame:SetScript("OnUpdate", function (self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        self:Update()
    end
end)


nekometer.frames = nekometer.frames or {}
nekometer.frames.main = frame