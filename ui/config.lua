local _, nekometer = ...

---@class frame
local frame = CreateFrame("Frame", "NekometerConfig")

function frame:CreateSlider(min, max, step, format)
    local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
    slider:SetWidth(350)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.tooltipText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.tooltipText:SetPoint("BOTTOM", slider, "BOTTOM", 0, -8)
    slider:SetScript("OnValueChanged", function(s, value)
        local v = value
        if format then
            v = string.format(format, v)
        end
        s.tooltipText:SetText(v)
    end)
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

local barCountSliderText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
barCountSliderText:SetPoint("TOPLEFT", catGlobal, "BOTTOMLEFT", 0, -16)
barCountSliderText:SetText("Number of bars displayed")

local barCountSlider = frame:CreateSlider(1, 40, 1)
barCountSlider:SetPoint("TOPLEFT", barCountSliderText, "BOTTOMLEFT", 0, -8)

local mergePetsCheckbox = frame:CreateCheckbox("Merge Pets with their owners")
mergePetsCheckbox:SetPoint("TOPLEFT", barCountSlider, "BOTTOMLEFT", 0, -16)

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

local damageBreakdownCheckbox = frame:CreateCheckbox("Damage Breakdown")
damageBreakdownCheckbox:SetPoint("TOPLEFT", damageCheckbox, "TOPRIGHT", 100, 0)

local healingBreakdownCheckbox = frame:CreateCheckbox("Healing Breakdown")
healingBreakdownCheckbox:SetPoint("TOPLEFT", dpsCurrentCheckbox, "TOPRIGHT", 100, 0)

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

local smoothingSlider = frame:CreateSlider(0.1, 0.9, 0.1, "%.1f")
smoothingSlider:SetPoint("TOPLEFT", smoothingSliderText, "BOTTOMLEFT", 0, -8)

local resetButton = frame:CreateButton("Defaults")
resetButton:SetPoint("BOTTOM", 0, 10)
resetButton:SetScript("OnClick", function()
    StaticPopup_Show("NEKOMETER_RESET_SETTINGS")
end)

function frame:OnRefresh()
    barCountSlider:SetValue(NekometerConfig.window.bars)
    mergePetsCheckbox:SetChecked(NekometerConfig.mergePets)
    classColorsCheckbox:SetChecked(NekometerConfig.classColors)
    damageCheckbox:SetChecked(self:GetMeterConfig("damage").enabled)
    dpsCurrentCheckbox:SetChecked(self:GetMeterConfig("dps_current").enabled)
    dpsCombatCheckbox:SetChecked(self:GetMeterConfig("dps_combat").enabled)
    healingCheckbox:SetChecked(self:GetMeterConfig("healing").enabled)
    damageBreakdownCheckbox:SetChecked(self:GetMeterConfig("damage_breakdown"))
    healingBreakdownCheckbox:SetChecked(self:GetMeterConfig("healing_breakdown"))
    windowSlider:SetValue(self:GetMeterConfig("dps_current").window)
    smoothingSlider:SetValue(self:GetMeterConfig("dps_current").smoothing)
end

function frame:OnCommit()
    if self:allMetersDisabled() then
        damageCheckbox:SetChecked(true)
    end

    -- reload might be required
    local barCount = barCountSlider:GetValue()
    if barCount ~= NekometerConfig.window.bars then
        NekometerConfig.window.bars = barCount
        nekometer.reloadRequired = true
    end
    self:commitMeter("damage", damageCheckbox:GetChecked())
    self:commitMeter("dps_current", dpsCurrentCheckbox:GetChecked())
    self:commitMeter("dps_combat", dpsCombatCheckbox:GetChecked())
    self:commitMeter("healing", healingCheckbox:GetChecked())
    self:commitMeter("damage_breakdown", damageBreakdownCheckbox:GetChecked())
    self:commitMeter("healing_breakdown", healingBreakdownCheckbox:GetChecked())

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
        not healingCheckbox:GetChecked() and
        not damageBreakdownCheckbox:GetChecked() and
        not healingBreakdownCheckbox:GetChecked()
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
