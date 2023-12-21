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
    if item.class then
        local color = C_ClassColor.GetClassColor(item.class)
        bar:SetColorFill(color.r, color.g, color.b, 0.7)
    else
        local color = NekometerConfig.neutralColor
        bar:SetColorFill(color.r, color.g, color.b, color.a)
    end
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
    bar:SetSize(200, 20)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetPoint("TOPLEFT", 0, index * -20)
    bar:SetColorFill(0.3, 0.3, 0.3, 0.7)
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", bar, "LEFT", 0, 0)
    bar["text"] = text
    local val = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    val:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
    bar["value"] = val
    return bar
end

nekometer.frames.bars = bars
