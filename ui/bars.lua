local _, nekometer = ...

local mainFrame = nekometer.frames.main

--[[
    We manage bar frames through this interface, because it is
    not possible to dispose a Frame once it has been created.
]]
local bars = {
    count = 0,
}

-- Display a report, creating new bars if neccessary.
function bars:Display(report)
    local size = #report
    self:setCount(size)
    if size > 0 then
        local maxValue = report[1].value
        for i, item in ipairs(report) do
            self:setData(i, item, maxValue)
        end
    end
end

function bars:setData(index, item, maxValue)
    local bar = self[index]
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(item.value)
    bar.text:SetText(item.name)
    bar.value:SetText(AbbreviateNumbers(item.value))
    local c
    if item.class then
        c = C_ClassColor.GetClassColor(item.class)
        c.a = 0.7
    else
        c = NekometerConfig.neutralColor
    end
    bar:SetColorFill(c.r, c.g, c.b, c.a)
end

function bars:setCount(count)
    -- create the required amount of bars
    for i = self.count + 1, count do
        self[i] = self:create(i)
    end
    -- bars 1..count should be visible
    for i = 1, count do
        self[i]:Show()
    end
    -- bars after count should be hidden
    for i = count + 1, self.count do
        self[i]:Hide()
    end
    -- finally commit the count
    self.count = count
end

function bars:create(index)
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
