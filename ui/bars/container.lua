local _, nekometer = ...

local mainFrame = nekometer.frames.main
local bar = nekometer.bars.bar

local container = {
    frame = CreateFrame("Frame", nil, mainFrame),
    maxBars = 40,
    scrollOffset = 0,
    report = {},
}

function container:Init()
    self.frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -NekometerConfig.titleBarHeight)
    self.frame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
    for i=1, self.maxBars do
        table.insert(self, bar:new(i))
    end
end

function container:Display(report)
    self.report = report
    self:Redraw()
end

function container:Redraw()
    local numVisible = self:getVisibleBarCount()
    self:UpdateData(numVisible)
    self:UpdateVisibility(numVisible)
end

function container:UpdateVisibility(numVisible)
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

function container:UpdateData(numVisible)
    local maxValue = self:getMaxValue()
    local source = self.report.source
    for i=1, numVisible do
        local item = self.report[i + self.scrollOffset]
        local bar = self[i]
        if item and item.value and item.value < math.huge then
            item.maxValue = maxValue
            item.source = source
            item.position = i + self.scrollOffset
            bar:SetData(item)
        end
    end
end

function container:ScrollUp()
    if self.scrollOffset > 0 then
        self.scrollOffset = self.scrollOffset - 1
        self:Redraw()
    end
end

function container:ScrollDown()
    local numBars = self:getVisibleBarCount()
    local numData = #self.report
    local clippedBars = numData - numBars
    if clippedBars > 0 and self.scrollOffset < clippedBars then
        self.scrollOffset = self.scrollOffset + 1
        self:Redraw()
    end
end

function container:ScrollToTop()
    self.scrollOffset = 0
    self:Redraw()
end

function container:getVisibleBarCount()
    local _, height = self.frame:GetSize()
    return math.floor(height / NekometerConfig.barHeight)
end

function container:getMaxValue()
    local maxValue = 0
    if #self.report > 0 and self.report[1].value < math.huge then
        maxValue = self.report[1].value
    end
    return maxValue
end

nekometer.frames.barContainer = container
