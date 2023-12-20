local _, nekometer = ...

local config = {}

local defaults = {
    mergePets = true,
    classColors = true,
    meterOrder = { "damage", "dps_current", "dps_combat", "healing" },
    damage = {
        enabled = true,
    },
    dps_current = {
        enabled = true,
        window = 3,
        smoothing = 0.7,
    },
    dps_combat = {
        enabled = true,
    },
    healing = {
        enabled = true,
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