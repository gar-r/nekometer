local _, nekometer = ...

local mainFrame = nekometer.frames.main

---@class BackdropTemplate:Frame
local titleBar = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
titleBar:SetSize(200, 20)
titleBar:SetPoint("TOPLEFT")
titleBar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
})
titleBar:SetBackdropColor(0.1, 0.1, 0.1, 1)

titleBar:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" and mainFrame:IsMovable() then
        mainFrame:StartMoving()
    end
end)

titleBar:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        mainFrame:StopMovingOrSizing()
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
