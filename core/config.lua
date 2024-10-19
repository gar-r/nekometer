local _, nekometer = ...

nekometer.meters = {
    "damage",
    "dpsCombat",
    "dpsCurrent",
    "healing",
    "damageBreakdown",
    "healingBreakdown",
    "deaths",
    "interrupts",
    "dispels",
    "overheal",
}

nekometer.defaults = {
    -- version (increment to force wipe on init)
    configVersion = 11,

    -- general
    updateRate = 0.5,
    currentMeterIndex = 1,
    mergePets = true,
    classColors = true,

    -- auto hide
    autoHide = false,
    autoHideDelay = 5,
    autoHideDisabledInInstances = true,
    autoHideDisabledInGroups = true,

    -- auto reset
    autoResetConfirmation = false,
    autoResetOnEnterInstance = false,
    autoResetOnEnterDelve = false,

    -- window
    windowShown = true,
    windowLocked = false,
    windowMinWidth = 235,
    windowMinHeight = 80,
    windowColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.3
    },

    -- title bar
    titleBarHeight = 20,
    titleBarColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 1
    },

    -- bars
    barHeight = 20,
    barNeutralColor = {
        r = 0.2,
        g = 0.2,
        b = 0.2,
        a = 0.85
    },
    barTextColor = {
        r = 1,
        g = 1,
        b = 0.85
    },
    barPositionDisplayEnabled = false,
    barIconsDisplayEnabled = false,

    -- enabled meters
    damageEnabled = true,
    dpsCombatEnabled = true,
    dpsCurrentEnabled = true,
    healingEnabled = true,
    damageBreakdownEnabled = true,
    healingBreakdownEnabled = true,
    deathsEnabled = false,
    interruptsEnabled = false,
    dispelsEnabled = false,
    overhealEnabled = false,

    -- meter specific
    dpsCurrentWindowSize = 3,
    dpsCurrentSmoothing = 0.7,
}

local function needsWipe()
    return not NekometerConfig
        or not NekometerConfig.configVersion
        or NekometerConfig.configVersion < nekometer.defaults.configVersion
end

nekometer.init = function()
    if needsWipe() then
        nekometer.wipe()
    end
end

nekometer.wipe = function()
    NekometerConfig = CopyTable(nekometer.defaults)
end

nekometer.isMeterEnabled = function(key)
    return NekometerConfig[key .. "Enabled"]
end