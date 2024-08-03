local _, nekometer = ...

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", "NekometerMainFrame", UIParent, "BackdropTemplate")

function frame:Init()
    self.scrollOffset = 0
    self:SetPoint("CENTER")
    self:SetWidth(NekometerConfig.windowWidth)
    self:SetHeight(NekometerConfig.titleBarHeight + NekometerConfig.barCount * NekometerConfig.barHeight)
    self:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    local c = NekometerConfig.windowColor
    self:SetBackdropColor(c.r, c.g, c.b, c.a)
    self:EnableMouse(true)
    self:SetMovable(true)
    self:SetScript("OnUpdate", self.OnUpdate)
    self:SetScript("OnMouseWheel", self.OnMouseWheel)
    self:SetShown(NekometerConfig.windowShown and not NekometerConfig.autoHide)
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

nekometer.frames = nekometer.frames or {}
nekometer.frames.main = frame
