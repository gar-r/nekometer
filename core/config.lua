local _, nekometer = ...

local config = {}

local defaults = {
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

function config:Init()
    if NekometerConfig.initialized then
        self:import(NekometerConfig)
    else
        self:import(defaults)
        self.initialized = true
    end
end

function config:Reset()
    self:import(defaults)
end

function config:import(src)
    for k, v in pairs(src) do
        self[k] = v
    end
end

nekometer.config = config