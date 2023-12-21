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

frame.currentMeterIndex = 1

function frame:GetCurrentMeter()
    return nekometer.enabledMeters[self.currentMeterIndex]
end

function frame:ResetCurrentMeter()
    for _, meter in ipairs(nekometer.enabledMeters) do
        if meter.Reset then
            meter:Reset()
        end
    end
    self:Update()
end

function frame:NextMeter()
    if self.currentMeterIndex == #nekometer.enabledMeters then
        self.currentMeterIndex = 1
    else self.currentMeterIndex = self.currentMeterIndex + 1
    end
    self:Update()
end

function frame:PrevMeter()
    if self.currentMeterIndex == 1 then
        self.currentMeterIndex = #nekometer.enabledMeters
    else self.currentMeterIndex = self.currentMeterIndex - 1
    end
    self:Update()
end

function frame:Update()
    if nekometer.enabledMeters then
        local bars = nekometer.frames.bars
        local meter = self:GetCurrentMeter()
        bars:Display(meter:Report())
    end
end

function frame:CheckState()
    if nekometer.reloadRequired then
        nekometer.reloadRequired = false
        nekometer.resetRequired = false
        StaticPopup_Show("NEKOMETER_RELOAD")
    end
    if nekometer.resetRequired then
        nekometer.resetRequired = false
        StaticPopup_Show("NEKOMETER_RESET")
    end
end

frame:SetScript("OnUpdate", function (self, elapsed)
    self.CheckState()
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        self:Update()
    end
end)


nekometer.frames = nekometer.frames or {}
nekometer.frames.main = frame