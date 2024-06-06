local addonName, nekometer = ...

local defaults = nekometer.defaults

local config = {
    needsReset = false,     -- need to reset meter data after the changes are applied
    needsReload = false,    -- need to reload the ui after the changes are applied
}

function config:Init()
    self.category, self.layout = Settings.RegisterVerticalLayoutCategory("Nekometer Settings")
    self.category.ID = addonName

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Global Options"))
    self:CreateProxiedSlider("Number of bars", "How many bars the Nekometer window will display", 1, 40, 1, "barCount")
    self:CreateProxiedCheckBox("Merge pets with their owners", "Enable to combine pet data with their owner", "mergePets")
    self:CreateProxiedCheckBox("Use class colors for bars", "Enable to color bars with respective class colors", "classColors")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Meters"))
    self:CreateProxiedCheckBox("Damage", "Shows total damage since last reset", "damageEnabled")
    self:CreateProxiedCheckBox("Dps (combat)", "Shows damage per second for the current combat", "dpsCombatEnabled")
    self:CreateProxiedCheckBox("Dps (current)", "Shows damage per second using a sliding time window", "dpsCurrentEnabled")
    self:CreateProxiedCheckBox("Healing", "Shows total healing since last reset", "healingEnabled")
    self:CreateProxiedCheckBox("Damage Breakdown", "Shows damage breakdown by ability for your character", "damageBreakdownEnabled")
    self:CreateProxiedCheckBox("Healing Breakdown", "Shows healing breakdown by ability for your character", "healingBreakdownEnabled")
    self:CreateProxiedCheckBox("Deaths", "Shows the number of deaths since last reset", "deathsEnabled")
    self:CreateProxiedCheckBox("Interrupts", "Shows the number of successful interrupts since last reset", "interruptsEnabled")
    self:CreateProxiedCheckBox("Dispels", "Shows the number of successful dispels or spell-steals since last reset", "dispelsEnabled")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Advanced Options"))
    self:CreateProxiedSlider("Data window size", "The sliding window size for the dps(current) meter", 1, 10, 1, "dpsCurrentWindowSize")
    self:CreateProxiedSlider("Smoothing factor", "The smoothing factor for the dps(current) meter", 0.1, 0.9, 0.1, "dpsCurrentSmoothing")

    SettingsPanel:SetScript("OnHide", function () self:OnSettingsClosed() end)
    Settings.RegisterAddOnCategory(self.category)
end

function config:CreateProxiedSlider(name, tooltip, min, max, step, variable)
    local sliderOptions = Settings.CreateSliderOptions(min, max, step)
    if step < 1 then
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
            function(v)
                return string.format("%.1f", v)
            end)
    else
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    end
    local setting = Settings.RegisterAddOnSetting(self.category, name, variable,
        Settings.VarType.Number, defaults[variable])
    setting:SetValue(NekometerConfig[variable])
    Settings.CreateSlider(self.category, setting, sliderOptions, tooltip)
    Settings.SetOnValueChangedCallback(variable, function(_, s, v)
        self:OnSettingChanged(_, s, v)
    end)
end

function config:CreateProxiedCheckBox(name, tooltip, variable)
    local setting = Settings.RegisterAddOnSetting(self.category, name, variable,
        Settings.VarType.Boolean, defaults[variable])
    setting:SetValue(NekometerConfig[variable])
    Settings.CreateCheckBox(self.category, setting, tooltip)
    Settings.SetOnValueChangedCallback(variable, function(_, s, v)
        self:OnSettingChanged(_, s, v)
    end)
end

function config:OnSettingChanged(_, setting, value)
    local variable = setting:GetVariable()
    NekometerConfig[variable] = value
    self:updateResetNeeded(variable)
    self:updateReloadNeeded(variable)
end

function config:OnSettingsClosed()
    -- at least one meter should be enabled
    if self:allMetersDisabled() then
        NekometerConfig.damageEnabled = true
        self.needsReload = true
    end

    -- add a small delay to avoid our static popups to draw over game frames
    C_Timer.After(1, function ()
        if self.needsReload then
            self.needsReload = false
            self.needsReinit = false
            self.needsReset = false
            NekometerConfig.currentMeterIndex = 1
            StaticPopup_Show("NEKOMETER_RELOAD")
        elseif self.needsReset then
                self.needsReset = false
                StaticPopup_Show("NEKOMETER_RESET")
        end
    end)
end

function config:updateResetNeeded(changedVariable)
    self.needsReset = changedVariable == "mergePets"
end

function config:updateReloadNeeded(changedVariable)
    if changedVariable == "barCount" then
        self.needsReload = true
        return
    end
    for _, meter in ipairs(nekometer.meters) do
        local meterEnabledVariable = meter .. "Enabled"
        if changedVariable == meterEnabledVariable then
            self.needsReload = true
            return
        end
    end
end

function config:allMetersDisabled()
    for _, meter in ipairs(nekometer.meters) do
        if nekometer.isMeterEnabled(meter) then
            return false
        end
    end
    return true
end

nekometer.frames.config = config
