local _, nekometer = ...

local tutorialFrame = {}

function tutorialFrame:Show(target, text)
    self.target = target
    ActionButton_ShowOverlayGlow(target)
    self.bubbleFrame:SetPoint("BOTTOM", target, "TOP", 0, 0)
    self.textFrame:SetPoint("BOTTOM", self.bubbleFrame, "TOP", 0, 0)
    self.textFrame.text:SetText(text)
    local height = self.textFrame.text:GetStringHeight() + 8
    self.textFrame:SetSize(200, height)
    self.bubbleFrame:Show()
    self.textFrame:Show()
end

function tutorialFrame:Hide()
    ActionButton_HideOverlayGlow(tutorialFrame.target)
    self.textFrame:Hide()
    self.bubbleFrame:Hide()
end

local bubbleFrame = CreateFrame("Frame", "NekometerTutorialBubbleFrame", UIParent, "BackdropTemplate")
bubbleFrame:SetSize(16, 16)
bubbleFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\CHATBUBBLE-TAIL",
})
bubbleFrame:SetBackdropColor(0, 0, 0, 0.8)
tutorialFrame.bubbleFrame = bubbleFrame

local textFrame = CreateFrame("Frame", "NekometerTutorialTextFrame", UIParent, "BackdropTemplate")
textFrame:SetSize(200, 24)
textFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    tile = true,
    tileSize = 16,
})
textFrame:SetBackdropColor(0, 0, 0, 0.8)
tutorialFrame.textFrame = textFrame

local text = textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
text:SetTextColor(1, 0.9, 0, 1)
text:SetPoint("LEFT", textFrame, "LEFT", 8, 0)
text:SetPoint("RIGHT", textFrame, "RIGHT", -20, 0)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")
textFrame.text = text

local closeButton = CreateFrame("Button", nil, textFrame)
closeButton:SetSize(14, 14)
local normal = closeButton:CreateTexture(nil, "BACKGROUND")
normal:SetTexture("Interface/Buttons/UI-StopButton")
local highlight = closeButton:CreateTexture(nil, "HIGHLIGHT")
highlight:SetTexture("Interface/Buttons/UI-StopButton")
closeButton:SetNormalTexture(normal)
closeButton:SetHighlightTexture(highlight)
closeButton:SetPoint("TOPRIGHT", textFrame, "TOPRIGHT", -4, -4)
closeButton:SetScript("OnClick", function()
    tutorialFrame:Hide()
end)
textFrame.closeButton = closeButton

nekometer.frames.tutorial = tutorialFrame