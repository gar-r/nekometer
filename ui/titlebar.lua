local _, nekometer = ...

local mainFrame = nekometer.frames.main
local commands = nekometer.commands

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

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")

local function CreateTitleBarButton(texture, onClick)
    local button = CreateFrame("Button", nil, titleBar)
    button:SetSize(12, 12)
    button:SetNormalTexture(texture)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button:GetHighlightTexture():SetBlendMode("ADD")
    button:SetScript("OnClick", onClick)
    return button
end

local prevButton = CreateTitleBarButton("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonDown-Up", function ()
    mainFrame:PrevMeter()
    titleText:SetText(mainFrame:GetCurrentMeter().title)
end)
prevButton:SetSize(18, 18)
prevButton:SetPoint("LEFT", titleBar, "LEFT", 0, 0)

local nextButton = CreateTitleBarButton("Interface\\MINIMAP\\UI-Minimap-MinimizeButtonUp-Up", function ()
    mainFrame:NextMeter()
    titleText:SetText(mainFrame:GetCurrentMeter().title)
end)
nextButton:SetSize(18, 18)
nextButton:SetPoint("LEFT", prevButton, "RIGHT", -5, 0)

titleText:SetPoint("LEFT", nextButton, "RIGHT", 5, 0)
titleText:SetText("Damage")

local closeButton = CreateTitleBarButton("Interface\\Buttons\\UI-StopButton", function ()
    commands:toggle()
end)
closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -3, 0)

local settingsButton = CreateTitleBarButton("Interface\\Buttons\\UI-OptionsButton", function ()
    commands:config()
end)
settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -3, 0)

local resetButton = CreateTitleBarButton("Interface\\Buttons\\UI-RefreshButton", function ()
    commands:reset()
end)
resetButton:SetPoint("RIGHT", settingsButton, "LEFT", -3, 0)
