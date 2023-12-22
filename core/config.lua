local _, nekometer = ...

local defaults = {
    version = 3,
    updateRate = 0.5,
    window = {
        color = { r = 0, g = 0, b = 0, a = 0.3 },
        width = 215,
        bars = 6,
    },
    titleBar = {
        height = 20,
        color = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
    },
    bars = {
        height = 20,
        neutralColor = { r = 0.3, g = 0.3, b = 0.3, a = 0.7 },
    },
    mergePets = true,
    classColors = true,
    meters = {
        {
            key = "damage",
            enabled = true,
        },
        {
            key = "dps_current",
            enabled = true,
            window = 3,
            smoothing = 0.7,
        },
        {
            key = "dps_combat",
            enabled = true,
        },
        {
            key = "healing",
            enabled = true,
        }
    },
}

local function needsWipe()
    return not NekometerConfig.version or NekometerConfig.version < defaults.version
end

nekometer.init = function ()
    if needsWipe() then
        nekometer.wipe()
    end
end

nekometer.wipe = function ()
    NekometerConfig = CopyTable(defaults)
end