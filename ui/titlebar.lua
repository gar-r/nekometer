local _, nekometer = ...

local mainFrame = nekometer.frames.main
local commands = nekometer.commands

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

function frame:Init()
    self:SetWidth(NekometerConfig.window.width)
    self:SetHeight(NekometerConfig.titleBar.height)
    frame:SetPoint("TOPLEFT")
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    local c = NekometerConfig.titleBar.color
    frame:SetBackdropColor(c.r, c.g, c.b, c.a)
end

frame:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" and mainFrame:IsMovable() then
        mainFrame:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        mainFrame:StopMovingOrSizing()
    end
end)

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

local function CreateTitleBarButton(texture, onClick)
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(13, 13)
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
prevButton:SetPoint("LEFT", frame, "LEFT", 0, 0)

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
closeButton:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

local settingsButton = CreateTitleBarButton("Interface\\Buttons\\UI-OptionsButton", function ()
    commands:config()
end)
settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -3, 0)

local resetButton = CreateTitleBarButton("Interface\\Buttons\\UI-RefreshButton", function ()
    commands:reset()
end)
resetButton:SetPoint("RIGHT", settingsButton, "LEFT", -3, 0)

nekometer.frames.titleBar = frame