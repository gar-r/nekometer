local _, nekometer = ...

local autoreset = {}

local commands = nekometer.commands

function autoreset:HandleZoneChange()
    if NekometerConfig.autoResetOnEnterInstance and IsInInstance() then
       self:reset()
    end
end

function autoreset:HandleDelveUpdate()
    if NekometerConfig.autoResetOnEnterDelve and self:isInDelve() then
        self:reset()
    end
end

function autoreset:reset()
    if NekometerConfig.autoResetConfirmation then
        commands:resetWithConfirmation()
    else
        commands:reset()
    end
end

function autoreset:isInDelve()
    local _, _, _, mapId = UnitPosition("player")
    return C_DelvesUI.HasActiveDelve(mapId)
end

nekometer.autoreset = autoreset