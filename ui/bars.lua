local _, nekometer = ...

local mainFrame = nekometer.frames.main

local bars = {}

function bars:Init()
    for i=1, NekometerConfig.window.bars do
        local bar = self:createBar(i)
        table.insert(self, bar)
    end
end

function bars:Display(report, page)
    page = page or 1
    local from = (page-1) * #self + 1
    local to = page * #self
    local maxValue = 0
    if #report > 0 then
        maxValue = report[1].value
    end
    for i, bar in ipairs(self) do
        local idx = (page-1) * #self + i
        local item = report[idx]
        if item then
            self:setData(bar, report[idx], maxValue)
            bar:Show()
        else
            bar:Hide()
        end
    end
end

function bars:setData(bar, item, maxValue)
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(item.value)
    bar.text:SetText(item.name)
    bar.value:SetText(AbbreviateNumbers(item.value))
    local c
    if item.class then
        c = C_ClassColor.GetClassColor(item.class)
        c.a = 0.7
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
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", bar, "LEFT", 5, 0)
    bar["text"] = text
    local val = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    val:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    bar["value"] = val
    return bar
end

nekometer.frames.bars = bars
