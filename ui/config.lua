local _, nekometer = ...

---@class frame
local frame = CreateFrame("Frame", "NekometerConfig", UIParent)
frame.name = "Nekometer"

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

local dpsRefreshSlider = frame:CreateSlider(1, 30, 1)
dpsRefreshSlider:SetPoint("TOP", frame, 0, -20)
dpsRefreshSlider:SetValue(2)

local dpsSmoothingSlider = frame:CreateSlider(0.1, 0.9, 0.1)
dpsSmoothingSlider:SetPoint("BOTTOM", dpsRefreshSlider, 0, -40)
dpsSmoothingSlider:SetValue(0.7)

local saveButton = frame:CreateButton("Save")
saveButton:SetPoint("CENTER", dpsSmoothingSlider, 0, -40)

local resetButton = frame:CreateButton("Reset Settings")
resetButton:SetPoint("CENTER", saveButton, 0, -40)

local checkbox = frame:CreateCheckbox("Text Checkbox")
checkbox:SetPoint("CENTER", resetButton, 0, -40)

InterfaceOptions_AddCategory(frame)

nekometer.frames = nekometer.frames or {}
nekometer.frames.config = frame
