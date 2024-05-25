local _, nekometer = ...

local mainFrame = nekometer.frames.main
local commands = nekometer.commands

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

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
    titleText:SetText(mainFrame:GetCurrentMeter().title)
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

local function CreateTitleBarButton(texturePath, onClick)
    local button = CreateFrame("Button", nil, frame)
    local texture = button:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(texturePath)
    button["texture"] = texture
    button:SetSize(14, 14)
    button:SetNormalTexture(texture)
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    button:GetHighlightTexture():SetBlendMode("ADD")
    button:SetScript("OnClick", onClick)
    return button
end

local prevButton = CreateTitleBarButton("Interface\\CHATFRAME\\ChatFrameExpandArrow", function ()
    mainFrame:PrevMeter()
    titleText:SetText(mainFrame:GetCurrentMeter().title)
end)
prevButton["texture"]:SetTexCoord(1, 0, 0, 1)
prevButton:SetPoint("LEFT", frame, "LEFT", 5, 0)

local nextButton = CreateTitleBarButton("Interface\\CHATFRAME\\ChatFrameExpandArrow", function ()
    mainFrame:NextMeter()
    titleText:SetText(mainFrame:GetCurrentMeter().title)
end)
nextButton:SetPoint("LEFT", prevButton, "RIGHT", -3, 0)

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