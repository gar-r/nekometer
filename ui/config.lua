local _, nekometer = ...

---@class frame
local frame = CreateFrame("Frame", "NekometerConfig")

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

function frame:GetMeterConfig(key)
    for _, cfg in ipairs(NekometerConfig.meters) do
        if cfg.key == key then
            return cfg
        end
    end
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
windowSliderText:SetText("Data window size")

local windowSlider = frame:CreateSlider(1, 10, 1)
windowSlider:SetPoint("TOPLEFT", windowSliderText, "BOTTOMLEFT", 0, -8)

local smoothingSliderText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
smoothingSliderText:SetPoint("TOPLEFT", windowSlider, "BOTTOMLEFT", 0, -16)
smoothingSliderText:SetText("Smoothing factor")

local smoothingSlider = frame:CreateSlider(0.1, 0.9, 0.1)
smoothingSlider:SetPoint("TOPLEFT", smoothingSliderText, "BOTTOMLEFT", 0, -8)

local resetButton = frame:CreateButton("Defaults")
resetButton:SetPoint("BOTTOM", 0, 10)
resetButton:SetScript("OnClick", function ()
    StaticPopup_Show("NEKOMETER_RESET_SETTINGS")
end)

function frame:OnRefresh()
    mergePetsCheckbox:SetChecked(NekometerConfig.mergePets)
    classColorsCheckbox:SetChecked(NekometerConfig.classColors)
    damageCheckbox:SetChecked(frame:GetMeterConfig("damage").enabled)
    dpsCurrentCheckbox:SetChecked(frame:GetMeterConfig("dps_current").enabled)
    dpsCombatCheckbox:SetChecked(frame:GetMeterConfig("dps_combat").enabled)
    healingCheckbox:SetChecked(frame:GetMeterConfig("healing").enabled)
    windowSlider:SetValue(frame:GetMeterConfig("dps_current").window)
    smoothingSlider:SetValue(frame:GetMeterConfig("dps_current").smoothing)
end

function frame:OnCommit()
    if self:allMetersDisabled() then
        damageCheckbox:SetChecked(true)
    end

    -- reload might be required
    self:commitMeter("damage", damageCheckbox:GetChecked())
    self:commitMeter("dps_current", dpsCurrentCheckbox:GetChecked())
    self:commitMeter("dps_combat", dpsCombatCheckbox:GetChecked())
    self:commitMeter("healing", healingCheckbox:GetChecked())

    -- reset might be required
    local mergePets = mergePetsCheckbox:GetChecked()
    if NekometerConfig.mergePets ~= mergePets then
        NekometerConfig.mergePets = mergePets
        nekometer.resetRequired = true
    end
    local classColors = classColorsCheckbox:GetChecked()
    if NekometerConfig.classColors ~= classColors then
        NekometerConfig.classColors = classColors
        nekometer.resetRequired = true
    end

    -- no reload or reset required
    local dpsCurrentCfg = frame:GetMeterConfig("dps_current")
    dpsCurrentCfg.window = windowSlider:GetValue()
    dpsCurrentCfg.smoothing = smoothingSlider:GetValue()
end

function frame:allMetersDisabled()
    return not damageCheckbox:GetChecked() and
           not dpsCurrentCheckbox:GetChecked() and
           not dpsCombatCheckbox:GetChecked() and
           not healingCheckbox:GetChecked()
end

function frame:commitMeter(key, newVal)
    local cfg = frame:GetMeterConfig(key)
    if cfg.enabled ~= newVal then
        cfg.enabled = newVal
        NekometerConfig.currentMeterIndex = 1
        nekometer.reloadRequired = true
    end
end


function frame:OnDefault()
    self:ResetSettings()
end

function frame:ResetSettings()
    nekometer.wipe()
    self:OnRefresh()
end

local settings = Settings.RegisterCanvasLayoutCategory(frame, "Nekometer")
settings.ID = "Nekometer"
Settings.RegisterAddOnCategory(settings)

nekometer.frames = nekometer.frames or {}
nekometer.frames.config = frame
