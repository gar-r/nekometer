local _, nekometer = ...

local bar = {
    left = {},
    right = {},
}

function bar:new(index)
    local container = nekometer.frames.barContainer.frame
    local frame = CreateFrame("StatusBar", nil, container)
    local height = NekometerConfig.barHeight
    local offset = (index-1) * height
    frame:SetHeight(height)
    frame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -offset)
    frame:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -offset)
    frame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    local o = {
        frame = frame,
        text = self:createFontString(frame, "LEFT"),
        value = self:createFontString(frame, "RIGHT"),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function bar:SetData(data)
    self:setColor(data.class)
    self.frame:SetMinMaxValues(0, data.maxValue)
    self.frame:SetValue(data.value)
    self.text:SetText(data.name)
    self.value:SetText(AbbreviateNumbers(data.value))
end

function bar:Show()
    self.frame:Show()
end

function bar:Hide()
    self.frame:Hide()
end

function bar:setColor(class)
    local c
    if NekometerConfig.classColors and class then
        c = C_ClassColor.GetClassColor(class)
        c.a = 0.6
    else
        c = NekometerConfig.barNeutralColor
    end
    self.frame:SetColorFill(c.r, c.g, c.b, c.a)
end

function bar:createFontString(frame, align)
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

nekometer.frames.bar = bar
