local _, nekometer = ...

local frame = CreateFrame("Frame", "NekometerChart", UIParent, "BackdropTemplate")
frame:SetPoint("CENTER")
frame:SetSize(200, 120)
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
})
frame:SetBackdropColor(0, 0, 0, 0.3)
frame:EnableMouse(true)
frame:SetMovable(true)

local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
titleBar:SetSize(200, 20)
titleBar:SetPoint("TOPLEFT")
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
})
titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1)

titleBar:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and frame:IsMovable() then
        frame:StartMoving()
    end
end)

titleBar:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        frame:StopMovingOrSizing()
    end
end)

local function CreateTitleBarButton(texture, onClick)
    local button = CreateFrame("Button", nil, titleBar)
    button:SetSize(12, 12)
    button:SetNormalTexture(texture)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button:GetHighlightTexture():SetBlendMode("ADD")
    button:SetScript("OnClick", onClick)
    return button
end

local prevButton = CreateTitleBarButton("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up")
prevButton:SetSize(18, 18)
prevButton:SetPoint("LEFT", titleBar, "LEFT", 0, 0)

local nextButton = CreateTitleBarButton("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up")
nextButton:SetSize(18, 18)
nextButton:SetPoint("LEFT", prevButton, "RIGHT", -5, 0)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", nextButton, "RIGHT", 5, 0)
titleText:SetText("Damage")

local closeButton = CreateTitleBarButton("Interface\\Buttons\\UI-StopButton")
closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -3, 0)

local settingsButton = CreateTitleBarButton("Interface\\Buttons\\UI-OptionsButton")
settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -3, 0)

local resetButton = CreateTitleBarButton("Interface\\Buttons\\UI-RefreshButton")
resetButton:SetPoint("RIGHT", settingsButton, "LEFT", -3, 0)

local function CreateBar(index)
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetSize(200, 20)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(55)
    
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", bar, "LEFT", 0, 0)
    bar["text"] = text
    
    local val = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    val:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
    bar["value"] = val

    bar:SetPoint("TOPLEFT", 0, index * -20)
    bar:SetColorFill(0.3, 0.3, 0.3, 0.7)
    
    return bar
end

local function SetBarData(bar, data, maxValue)
    bar:SetMinMaxValues(0, maxValue)
    if data then
        bar.text:SetText(data.name)
        bar.value:SetText(data.value)
        bar:SetValue(data.value)
    else
        bar.text:SetText("")
        bar.value:SetText("")
        bar:SetValue(0)
    end
end

local bars = {
    CreateBar(1),
    CreateBar(2),
    CreateBar(3),
    CreateBar(4),
    CreateBar(5),
}

function frame:UpdateBars()
    if nekometer.enabledMeters == nil then
        return
    end
    local meter = self.selectedMeter or nekometer.enabledMeters[1]
    local report = meter:Report()
    local maxValue = 100
    for i, bar in ipairs(bars) do
        if i == 1 and report[i] then
            maxValue = report[i].value
        end
        SetBarData(bar, report[i], maxValue)
    end
end

frame:SetScript("OnUpdate", function (self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then
        self.elapsed = 0
        self:UpdateBars()
    end
end)

frame:Show()

nekometer.frames = nekometer.frames or {}
nekometer.frames.chart = frame
