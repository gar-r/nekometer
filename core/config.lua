local _, nekometer = ...

local defaults = {
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

nekometer.init = function ()
    if not NekometerConfig.initialized then
        nekometer.reset()
        NekometerConfig.initialized = true
    end
end

nekometer.reset = function ()
    NekometerConfig = CopyTable(defaults)
end