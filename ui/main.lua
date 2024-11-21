local _, nekometer = ...

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", "NekometerMainFrame", UIParent, "BackdropTemplate")

function frame:Init()
    self:RestoreLayout()
    self:EnableMoveAndResize()
    self:SetBackground()
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

function frame:ToggleMode()
    local meter = self:GetCurrentMeter()
    local currentMode = nekometer.getMode(meter.key)
    local newMode
    if currentMode == "total" then
        newMode = "combat"
    else
        newMode = "total"
    end
    nekometer.setMode(meter.key, newMode)
    self:UpdateBars()
end

function frame:UpdateBars()
    if nekometer.enabledMeters then
        local barContainer = nekometer.frames.barContainer
        local meter = self:GetCurrentMeter()
        barContainer:Display(meter:Report())
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
    local barContainer = nekometer.frames.barContainer
    if delta > 0 then
        barContainer:ScrollUp()
    else
        barContainer:ScrollDown()
    end
end

function frame:SaveLayout()
    local point, _, relativePoint, x, y = frame:GetPoint()
    local w = frame:GetWidth()
    local h = frame:GetHeight()
    NekometerConfig.windowLayout = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
        w = w,
        h = h,
    }
end

function frame:RestoreLayout()
    local layout = NekometerConfig.windowLayout
    self:SetPoint(layout.point, nil, layout.relativePoint, layout.x, layout.y)
    self:SetSize(layout.w, layout.h)
end

function frame:EnableMoveAndResize()
    self:SetClampedToScreen(true)
    self:RegisterForDrag("LeftButton")
    self:SetMovable(true)
    self:EnableMouse(true)
    self:SetResizable(true)
    self:SetResizeBounds(NekometerConfig.windowMinWidth, NekometerConfig.windowMinHeight)
    self:SetScript("OnUpdate", self.OnUpdate)
    self:SetScript("OnMouseWheel", self.OnMouseWheel)
end

function frame:SetBackground()
    local c = NekometerConfig.windowColor
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    frame:SetBackdropColor(c.r, c.g, c.b, c.a)
end

nekometer.frames = nekometer.frames or {}
nekometer.frames.main = frame
