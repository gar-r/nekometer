local _, nekometer = ...

local config = nekometer.config

---@class frame
local frame = CreateFrame("Frame", "NekometerConfig")
frame.name = "Nekometer"
InterfaceOptions_AddCategory(frame)

function frame:CreateSlider(min, max, step)
    local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
    slider:SetWidth(350)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    return slider
end

function frame:CreateButton(text)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(125, 25)
    button:SetText(text)
    return button
end

function frame:CreateCheckbox(text)
    local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    checkbox["text"]:SetText(text)
    return checkbox
end

local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Nekometer Settings")

local catGlobal = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
catGlobal:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
catGlobal:SetText("Global options")

local mergePetsCheckbox = frame:CreateCheckbox("Merge Pets with their owners")
mergePetsCheckbox:SetPoint("TOPLEFT", catGlobal, "BOTTOMLEFT", 0, -8)

local classColorsCheckbox = frame:CreateCheckbox("Use class colors for bars")
classColorsCheckbox:SetPoint("TOPLEFT", mergePetsCheckbox, "BOTTOMLEFT", 0, -8)

local catMeters = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
catMeters:SetPoint("TOPLEFT", classColorsCheckbox, "BOTTOMLEFT", 0, -16)
catMeters:SetText("Enabled meters")

local damageCheckbox = frame:CreateCheckbox("Damage")
damageCheckbox:SetPoint("TOPLEFT", catMeters, "BOTTOMLEFT", 0, -8)

local dpsCurrentCheckbox = frame:CreateCheckbox("Dps (current)")
dpsCurrentCheckbox:SetPoint("TOPLEFT", damageCheckbox, "BOTTOMLEFT", 0, -8)

local dpsCombatCheckbox = frame:CreateCheckbox("Dps (combat)")
dpsCombatCheckbox:SetPoint("TOPLEFT", dpsCurrentCheckbox, "BOTTOMLEFT", 0, -8)

local healingCheckbox = frame:CreateCheckbox("Healing")
healingCheckbox:SetPoint("TOPLEFT", dpsCombatCheckbox, "BOTTOMLEFT", 0, -8)

local catAdvanced = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
catAdvanced:SetPoint("TOPLEFT", healingCheckbox, "BOTTOMLEFT", 0, -16)
catAdvanced:SetText("Advanced options")

local windowSliderText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
windowSliderText:SetPoint("TOPLEFT", catAdvanced, "BOTTOMLEFT", 0, -16)
windowSliderText:SetText("Window size")

local windowSlider = frame:CreateSlider(1, 10, 1)
windowSlider:SetPoint("TOPLEFT", windowSliderText, "BOTTOMLEFT", 0, -8)
windowSlider:SetValue(3)

local smoothingSliderText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
smoothingSliderText:SetPoint("TOPLEFT", windowSlider, "BOTTOMLEFT", 0, -16)
smoothingSliderText:SetText("Smoothing factor")

local smoothingSlider = frame:CreateSlider(0.1, 0.9, 0.1)
smoothingSlider:SetPoint("TOPLEFT", smoothingSliderText, "BOTTOMLEFT", 0, -8)
smoothingSlider:SetValue(0.7)

local saveButton = frame:CreateButton("Save")
saveButton:SetPoint("BOTTOM", frame, 70, 10)

local resetButton = frame:CreateButton("Reset")
resetButton:SetPoint("BOTTOM", frame, -70, 10)

nekometer.frames = nekometer.frames or {}
nekometer.frames.config = frame
