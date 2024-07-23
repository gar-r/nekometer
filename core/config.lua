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
}

nekometer.defaults = {
    -- version (increment to force wipe on init)
    configVersion = 9,

    -- general
    updateRate = 0.5,
    currentMeterIndex = 1,
    mergePets = true,
    classColors = true,

    -- window
    windowShown = true,
    windowWidth = 215,
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
    barCount = 6,
    barHeight = 20,
    barNeutralColor = {
        r = 0.3,
        g = 0.3,
        b = 0.3,
        a = 0.7
    },
    barTextColor = {
        r = 1,
        g = 1,
        b = 0.85
    },

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