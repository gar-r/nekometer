local _, nekometer = ...

local config = {}

local defaults = {
    testFlag = true,
}

function config:Init()
    if NekometerConfig ~= nil then
        self:import(NekometerConfig)
    else
        self:import(defaults)
    end
    
end

function config:Reset()
    self:import(defaults)
    self:resetFrames()
end

function config:import(src)
    for k, v in pairs(src) do
        self[k] = v
    end
end

function config:resetFrames()
    local chart = nekometer.chart
    chart:SetPoint("CENTER", 0, 0)
end

nekometer.config = config