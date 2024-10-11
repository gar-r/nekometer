local _, nekometer = ...

local mainFrame = nekometer.frames.main
local bar = nekometer.frames.bar

local barContainer = {
    frame = CreateFrame("Frame", nil, mainFrame),
    maxBars = 40,
    scrollOffset = 0,
    report = {},
}

function barContainer:Init()
    self.frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -NekometerConfig.titleBarHeight)
    self.frame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
    for i=1, self.maxBars do
        table.insert(self, bar:new(i))
    end
end

function barContainer:Display(report)
    self.report = report
    self:Redraw()
end

function barContainer:Redraw()
    self:UpdateData()
    self:UpdateVisibility()
end

function barContainer:UpdateVisibility()
    local numVisible = self:getVisibleBarCount()
    local numReport = #self.report
    if numVisible > numReport then
        numVisible = numReport
    end
    for i, b in ipairs(self) do
        if i <= numVisible then
            b:Show()
        else
            b:Hide()
        end
    end
end

function barContainer:UpdateData()
    local maxValue = self:getMaxValue()
    for i in ipairs(self.report) do
        local item = self.report[i + self.scrollOffset]
        if item and item.value and item.value < math.huge then
            item.maxValue = maxValue
            self[i]:SetData(item)
        end
    end
end

function barContainer:ScrollUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:Redraw()
    end
end

function barContainer:ScrollDown()
    local numBars = self:getVisibleBarCount()
    local numData = #self.report
    local clippedBars = numData - numBars
    if clippedBars > 0 and self.scrollOffset < clippedBars then
        self.scrollOffset = self.scrollOffset + 1
        self:Redraw()
    end
end

function barContainer:ScrollToTop()
    self.scrollOffset = 0
    self:Redraw()
end

function barContainer:getVisibleBarCount()
    local _, height = self.frame:GetSize()
    return math.floor(height / NekometerConfig.barHeight)
end

function barContainer:getMaxValue()
    local maxValue = 0
    if #self.report > 0 and self.report[1].value < math.huge then
        maxValue = self.report[1].value
    end
    return maxValue
end

nekometer.frames.barContainer = barContainer
