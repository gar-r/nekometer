local _, nekometer = ...

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", "NekometerMainFrame", UIParent, "BackdropTemplate")

function frame:Init()
    self.scrollOffset = 0
    self:SetPoint("CENTER")
    self:SetWidth(NekometerConfig.window.width)
    self:SetHeight(NekometerConfig.titleBar.height + NekometerConfig.window.bars * NekometerConfig.bars.height)
    self:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    local c = NekometerConfig.window.color
    self:SetBackdropColor(c.r, c.g, c.b, c.a)
    self:EnableMouse(true)
    self:SetMovable(true)
    self:SetScript("OnUpdate", self.OnUpdate)
    self:SetScript("OnMouseWheel", self.OnMouseWheel)
    self:SetShown(NekometerConfig.window.shown)
end

function frame:GetCurrentMeter()
    return nekometer.enabledMeters[NekometerConfig.currentMeterIndex]
end

function frame:ResetEnabledMeters()
    for _, meter in ipairs(nekometer.enabledMeters) do
        if meter.Reset then
            meter:Reset()
        end
    end
    self:UpdateBars()
end

function frame:NextMeter()
    if NekometerConfig.currentMeterIndex == #nekometer.enabledMeters then
        NekometerConfig.currentMeterIndex = 1
    else
        NekometerConfig.currentMeterIndex = NekometerConfig.currentMeterIndex + 1
    end
    self:UpdateBars()
end

function frame:PrevMeter()
    if NekometerConfig.currentMeterIndex == 1 then
        NekometerConfig.currentMeterIndex = #nekometer.enabledMeters
    else
        NekometerConfig.currentMeterIndex = NekometerConfig.currentMeterIndex - 1
    end
    self:UpdateBars()
end

function frame:UpdateBars()
    if nekometer.enabledMeters then
        local bars = nekometer.frames.bars
        local meter = self:GetCurrentMeter()
        bars:Display(meter:Report(), self.scrollOffset)
    end
end

function frame:OnUpdate(elapsed)
    self:CheckState()
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= NekometerConfig.updateRate then
        self.elapsed = 0
        self:UpdateBars()
    end
end

function frame:OnMouseWheel(delta)
    if delta > 0 then
        if self.scrollOffset > 0 then
            self.scrollOffset = self.scrollOffset - 1
        end
    else
        self.scrollOffset = self.scrollOffset + 1
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
