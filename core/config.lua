local _, nekometer = ...

local defaults = {
    version = 1,
    mergePets = true,
    classColors = true,
    neutralColor = {
        r = 0.3,
        g = 0.3,
        b = 0.3,
        a = 0.7
    },
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