local _, nekometer = ...

local mainFrame = nekometer.frames.main

local bars = {}

function bars:Init()
    for i=1, NekometerConfig.window.bars do
        local bar = self:createBar(i)
        table.insert(self, bar)
    end
end

function bars:Display(report, offset)
    offset = self:boundOffset(report, offset)
    local maxValue = self:calcMaxValue(report)
    for i, bar in ipairs(self) do
        local item = report[i + offset]
        -- value very rarely comes as inf, causing the bar to error
        if item and item.value and item.value < math.huge then
            self:setData(bar, item, maxValue)
            bar:Show()
        else
            bar:Hide()
        end
    end
end

function bars:boundOffset(report, offset)
    local maxOffset = #report - #self
    if maxOffset < 0 then
        maxOffset = 0
    end
    if offset > maxOffset then
        offset = maxOffset
    end
    return offset
end

function bars:calcMaxValue(report)
    local maxValue = 0
    if #report > 0 and report[1].value < math.huge then
        maxValue = report[1].value
    end
    return maxValue
end

function bars:setData(bar, item, maxValue)
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(item.value)
    bar.text:SetText(item.name)
    bar.value:SetText(AbbreviateNumbers(item.value))
    local c
    if item.class then
        c = C_ClassColor.GetClassColor(item.class)
        c.a = 0.6
    else
        c = NekometerConfig.bars.neutralColor
    end
    bar:SetColorFill(c.r, c.g, c.b, c.a)
end

function bars:createBar(index)
    local bar = CreateFrame("StatusBar", nil, mainFrame)
    local offset = NekometerConfig.titleBar.height
    local height = NekometerConfig.bars.height
    bar:SetWidth(NekometerConfig.window.width)
    bar:SetHeight(height)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetPoint("TOPLEFT", 0, -offset - (index-1) * height)
    bar["text"] = self:createFontString(bar, "LEFT")
    bar["value"] = self:createFontString(bar, "RIGHT")
    return bar
end

function bars:createFontString(frame, align)
    local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local color = NekometerConfig.bars.textColor
    fontString:SetTextColor(color.r, color.g, color.b)
    local offset = 5
    if align == "RIGHT" then
        offset = -5
    end
    fontString:SetPoint(align, frame, align, offset, 0)
    return fontString
end

nekometer.frames.bars = bars
