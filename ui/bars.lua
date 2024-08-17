local _, nekometer = ...

local mainFrame = nekometer.frames.main

local bars = {
    maxBars = 40,
    scrollOffset = 0,
    report = {},
}

function bars:Init()
    for i=1, self.maxBars do
        local bar = self:createBar(i)
        table.insert(self, bar)
    end
end

function bars:Display(report)
    self.report = report
    self:Redraw()
end

function bars:Redraw()
    self:UpdateData()
    self:UpdateVisibility()
end

function bars:UpdateVisibility()
    local numVisible = self:getVisibleBarCount()
    local numReport = #self.report
    if numVisible > numReport then
        numVisible = numReport
    end
    for i, bar in ipairs(self) do
        if i <= numVisible then
            bar:Show()
        else
            bar:Hide()
        end
    end
end

function bars:UpdateData()
    local maxValue = self:getMaxValue()
    for i in ipairs(self.report) do
        local item = self.report[i + self.scrollOffset]
        if item and item.value and item.value < math.huge then
            self:setData(self[i], item, maxValue)
        end
    end
end

function bars:ScrollUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:Redraw()
    end
end

function bars:ScrollDown()
    local numBars = self:getVisibleBarCount()
    local numData = #self.report
    local clippedBars = numData - numBars
    if clippedBars > 0 and self.scrollOffset < clippedBars then
        self.scrollOffset = self.scrollOffset + 1
        self:Redraw()
    end
end

function bars:ScrollToTop()
    self.scrollOffset = 0
    self:Redraw()
end

function bars:getVisibleBarCount()
    local offset = NekometerConfig.titleBarHeight
    local _, height = mainFrame:GetSize()
    return math.floor((height - offset) / NekometerConfig.barHeight)
end

function bars:getMaxValue()
    local maxValue = 0
    if #self.report > 0 and self.report[1].value < math.huge then
        maxValue = self.report[1].value
    end
    return maxValue
end

function bars:setData(bar, item, maxValue)
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(item.value)
    bar.text:SetText(item.name)
    bar.value:SetText(AbbreviateNumbers(item.value))
    local c
    if NekometerConfig.classColors and item.class then
        c = C_ClassColor.GetClassColor(item.class)
        c.a = 0.6
    else
        c = NekometerConfig.barNeutralColor
    end
    bar:SetColorFill(c.r, c.g, c.b, c.a)
end

function bars:createBar(index)
    local bar = CreateFrame("StatusBar", nil, mainFrame)
    local height = NekometerConfig.barHeight
    local offset = NekometerConfig.titleBarHeight + (index-1) * height
    bar:SetHeight(height)
    bar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -offset)
    bar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, -offset)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar["text"] = self:createFontString(bar, "LEFT")
    bar["value"] = self:createFontString(bar, "RIGHT")
    return bar
end

function bars:createFontString(frame, align)
    local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local color = NekometerConfig.barTextColor
    fontString:SetTextColor(color.r, color.g, color.b)
    local offset = 5
    if align == "RIGHT" then
        offset = -5
    end
    fontString:SetPoint(align, frame, align, offset, 0)
    return fontString
end

nekometer.frames.bars = bars
