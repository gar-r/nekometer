local addonName, nekometer = ...

local defaults = nekometer.defaults
local commands = nekometer.commands

local config = {
    needsReset = false,  -- need to reset meter data after the changes are applied
    needsReload = false, -- need to reload the ui after the changes are applied
}

function config:Init()
    self.category, self.layout = Settings.RegisterVerticalLayoutCategory("Nekometer")
    self.category.ID = addonName

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Global Options"))
    self:CreateProxiedCheckBox("Lock window", "Prevent the window from being moved or resized", "windowLocked")
    self:CreateProxiedCheckBox("Merge pets with their owners", "Enable to combine pet data with their owner", "mergePets")
    self:CreateProxiedCheckBox("Use class colors for bars", "Enable to color bars with respective class colors", "classColors")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Auto Hide"))
    self:CreateProxiedCheckBox("Hide when not in combat", "Hide Nekometer when not in combat, allowing more immersion", "autoHide")
    self:CreateProxiedSlider("Auto hide delay", "Wait this amount of seconds before hiding Nekometer", 0, 10, 1, "autoHideDelay")
    self:CreateProxiedCheckBox("Always show in instances", "Auto hide is disabled when the player is instanced", "autoHideDisabledInInstances")
    self:CreateProxiedCheckBox("Always show in groups", "Auto hide is disabled when the player is in a group", "autoHideDisabledInGroups")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Auto Reset"))
    self:CreateProxiedCheckBox("Ask for confirmation", "Ask for confirmation before automatic data reset", "autoResetConfirmation")
    self:CreateProxiedCheckBox("Reset on entering instances", "Automatically reset when entering an instance", "autoResetOnEnterInstance")
    self:CreateProxiedCheckBox("Reset on entering delves", "Automatically reset when entering a delve", "autoResetOnEnterDelve")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Bar Options"))
    self:CreateProxiedCheckBox("Display position", "Display a number for each bar, indicating the position", "barPositionDisplayEnabled")
    self:CreateProxiedCheckBox("Display icons", "Display icons for class specializations, and abilities on each bar", "barIconsDisplayEnabled")

    self.layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Meters"))
    self:CreateProxiedCheckBox("Damage", "Shows total damage since last reset", "damageEnabled")
    self:CreateProxiedCheckBox("Dps", "Shows damage per second", "dpsEnabled")
    self:CreateProxiedCheckBox("Healing", "Shows total healing since last reset", "healingEnabled")
    self:CreateProxiedCheckBox("Damage Breakdown", "Shows damage breakdown by ability for your character", "damageBreakdownEnabled")
    self:CreateProxiedCheckBox("Healing Breakdown", "Shows healing breakdown by ability for your character", "healingBreakdownEnabled")
    self:CreateProxiedCheckBox("Deaths", "Shows the number of deaths since last reset", "deathsEnabled")
    self:CreateProxiedCheckBox("Interrupts", "Shows the number of successful interrupts since last reset", "interruptsEnabled")
    self:CreateProxiedCheckBox("Dispels", "Shows the number of successful dispels or spell-steals since last reset", "dispelsEnabled")
    self:CreateProxiedCheckBox("Overhealing", "Shows the amount of overhealing done", "overhealEnabled")

    SettingsPanel:SetScript("OnHide", function() self:OnSettingsClosed() end)
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
    local setting = Settings.RegisterAddOnSetting(self.category, variable, variable, NekometerConfig,
        Settings.VarType.Number, name, defaults[variable])
    Settings.CreateSlider(self.category, setting, sliderOptions, tooltip)
    Settings.SetOnValueChangedCallback(variable, function(_, s, v)
        self:OnSettingChanged(_, s, v)
    end)
end

function config:CreateProxiedCheckBox(name, tooltip, variable)
    local setting = Settings.RegisterAddOnSetting(self.category, variable, variable, NekometerConfig,
        Settings.VarType.Boolean, name, defaults[variable])
    setting:SetValue(NekometerConfig[variable])
    Settings.CreateCheckbox(self.category, setting, tooltip)
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

    -- display main window based on auto hide setting and user state
    commands:show(NekometerConfig.windowShown and not NekometerConfig.autoHide)

    -- display the resizer based on the windowLocked setting
    local resizer = nekometer.frames.resizer
    resizer:SetShown(not NekometerConfig.windowLocked)

    -- add a small delay to avoid our static popups to draw over game frames
    C_Timer.After(1, function()
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
    for _, meter in ipairs(nekometer.meters) do
        local meterEnabledVariable = meter .. "Enabled"
        if changedVariable == meterEnabledVariable then
            self.needsReload = true
            return
        end
    end
    if changedVariable == "barPositionDisplayEnabled"
    or changedVariable == "barIconsDisplayEnabled" then
        self.needsReload = true
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
