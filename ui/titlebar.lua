local _, nekometer = ...

local mainFrame = nekometer.frames.main
local commands = nekometer.commands

---@class BackdropTemplate:Frame
local frame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

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
    frame:Update()
end

frame:SetScript("OnMouseDown", function(_, button)
    if not NekometerConfig.windowLocked
        and button == "LeftButton"
        and mainFrame:IsMovable()
    then
        mainFrame:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        mainFrame:StopMovingOrSizing()
        mainFrame:SaveLayout()
    end
end)

function frame:Update()
    local meter = mainFrame:GetCurrentMeter()
    local mode = nekometer.getMode(meter.key)
    self.titleText:SetText(meter.title)
    self:UpdateModeButton(mode)
end

-- icon texture will be set dynamically for this button
frame.modeButton = CreateTitleBarButton(nil, function()
    mainFrame:ToggleMode()
    frame:Update()
end)
frame.modeButton:SetPoint("LEFT", frame, "LEFT", 5, 0)

local modeButtonAssets = {
    ["total"] = {
        icon = "Interface/MINIMAP/TRACKING/WildBattlePet",
        texCoord = { left = 0, right = 0.65, up = 0, down = 0.65, },
    },
    ["combat"] = {
        icon = "Interface/GROUPFRAME/UI-GROUP-MAINASSISTICON",
        texCoord = nil,
    }
}
function frame:UpdateModeButton(mode)
    local modeButton = self.modeButton
    local icon = modeButtonAssets[mode].icon
    local texCoord = modeButtonAssets[mode].texCoord
    modeButton:SetNormalTexture(
        CreateTitleButtonTexture(modeButton, icon, "BACKGROUND", texCoord))
    modeButton:SetHighlightTexture(
        CreateTitleButtonTexture(modeButton, icon, "HIGHLIGHT", texCoord))
end

local function showToggleModeTutorial()
    if not NekometerConfig.toggleModeTutorialDisplayed then
        NekometerConfig.toggleModeTutorialDisplayed = true
        nekometer.frames.tutorial:Show(frame.modeButton,
            "Toggle between total and combat mode by clicking this button.")
    end
end

frame.prevButton = CreateTitleBarButton("Interface/CHATFRAME/ChatFrameExpandArrow",
    function()
        mainFrame:PrevMeter()
        showToggleModeTutorial()
        frame:Update()
    end,
    { left = 1, right = 0, up = 0, down = 1 })
frame.prevButton:SetPoint("LEFT", frame.modeButton, "RIGHT", 5, 0)

frame.nextButton = CreateTitleBarButton("Interface/CHATFRAME/ChatFrameExpandArrow",
    function()
        mainFrame:NextMeter()
        showToggleModeTutorial()
        frame:Update()
    end)
frame.nextButton:SetPoint("LEFT", frame.prevButton, "RIGHT", -3, 0)

frame.titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.titleText:SetPoint("LEFT", frame.nextButton, "RIGHT", 5, 0)
frame.titleText:SetText("Damage")

frame.closeButton = CreateTitleBarButton("Interface/Buttons/UI-StopButton",
    function()
        commands:toggle()
    end)
frame.closeButton:SetPoint("RIGHT", frame, "RIGHT", -3, 0)

frame.settingsButton = CreateTitleBarButton("Interface/Buttons/UI-OptionsButton",
    function()
        commands:config()
    end)
frame.settingsButton:SetPoint("RIGHT", frame.closeButton, "LEFT", -3, 0)

frame.resetButton = CreateTitleBarButton("Interface/Buttons/UI-RefreshButton",
    function()
        commands:resetWithConfirmation()
    end)
frame.resetButton:SetPoint("RIGHT", frame.settingsButton, "LEFT", -3, 0)

nekometer.frames.titleBar = frame
