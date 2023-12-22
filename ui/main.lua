local _, nekometer = ...

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", "NekometerMainFrame", UIParent, "BackdropTemplate")

function frame:Init()
    self.currentMeterIndex = 1
    self:SetPoint("CENTER")
    self:SetWidth(NekometerConfig.window.width)
    self:SetHeight(NekometerConfig.titleBar.height + NekometerConfig.window.bars * 20)
    self:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    self:SetBackdropColor(0, 0, 0, 0.3)
    self:EnableMouse(true)
    self:SetMovable(true)
    self:SetScript("OnUpdate", self.UpdateBars)
end

function frame:GetCurrentMeter()
    return nekometer.enabledMeters[self.currentMeterIndex]
end

function frame:ResetCurrentMeter()
    for _, meter in ipairs(nekometer.enabledMeters) do
        if meter.Reset then
            meter:Reset()
        end
    end
    self:UpdateBars()
end

function frame:NextMeter()
    if self.currentMeterIndex == #nekometer.enabledMeters then
        self.currentMeterIndex = 1
    else
        self.currentMeterIndex = self.currentMeterIndex + 1
    end
    self:UpdateBars()
end

function frame:PrevMeter()
    if self.currentMeterIndex == 1 then
        self.currentMeterIndex = #nekometer.enabledMeters
    else
        self.currentMeterIndex = self.currentMeterIndex - 1
    end
    self:UpdateBars()
end

function frame:UpdateBars()
    if nekometer.enabledMeters then
        local bars = nekometer.frames.bars
        local meter = self:GetCurrentMeter()
        bars:Display(meter:Report())
    end
end

function frame:OnUpdate(elapsed)
    self:CheckState()
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        self:UpdateBars()
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

nekometer.frames = nekometer.frames or {}
nekometer.frames.main = frame
