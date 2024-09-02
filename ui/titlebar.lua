local _, nekometer = ...

local mainFrame = nekometer.frames.main
local commands = nekometer.commands

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

function frame:Init()
    self:SetHeight(NekometerConfig.titleBarHeight)
    self:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
    self:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
    })
    local c = NekometerConfig.titleBarColor
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

function frame:RefreshTitle()
    titleText:SetText(mainFrame:GetCurrentMeter().title)
end

local function CreateTitleButtonTexture(button, path, drawLayer, coord)
    local texture = button:CreateTexture(nil, drawLayer)
    texture:SetTexture(path)
    if coord then
        texture:SetTexCoord(coord.left, coord.right, coord.up, coord.down)
    end
    return texture
end

local function CreateTitleBarButton(texturePath, onClick, texCoord)
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(14, 14)
    button:SetNormalTexture(CreateTitleButtonTexture(button, texturePath, "BACKGROUND", texCoord))
    button:SetHighlightTexture(CreateTitleButtonTexture(button, texturePath, "HIGHLIGHT", texCoord))
    button:SetScript("OnClick", onClick)
    return button
end

local prevButton = CreateTitleBarButton("Interface\\CHATFRAME\\ChatFrameExpandArrow",
    function()
        mainFrame:PrevMeter()
        frame:RefreshTitle()
    end,
    { left = 1, right = 0, up = 0, down = 1 })
prevButton:SetPoint("LEFT", frame, "LEFT", 5, 0)

local nextButton = CreateTitleBarButton("Interface\\CHATFRAME\\ChatFrameExpandArrow",
    function()
        mainFrame:NextMeter()
        frame:RefreshTitle()
    end)
nextButton:SetPoint("LEFT", prevButton, "RIGHT", -3, 0)

titleText:SetPoint("LEFT", nextButton, "RIGHT", 5, 0)
titleText:SetText("Damage")

local closeButton = CreateTitleBarButton("Interface\\Buttons\\UI-StopButton",
    function()
        commands:toggle()
    end)
closeButton:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

local settingsButton = CreateTitleBarButton("Interface\\Buttons\\UI-OptionsButton",
    function()
        commands:config()
    end)
settingsButton:SetPoint("RIGHT", closeButton, "LEFT", -3, 0)

local resetButton = CreateTitleBarButton("Interface\\Buttons\\UI-RefreshButton",
    function()
        commands:resetWithConfirmation()
    end)
resetButton:SetPoint("RIGHT", settingsButton, "LEFT", -3, 0)

nekometer.frames.titleBar = frame
