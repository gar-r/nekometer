local _, nekometer = ...

local commands = nekometer.commands

local autohide = {
    cancelTimer = false
}

function autohide:HandleCombatEntered()
    self.cancelTimer = true
    if NekometerConfig.windowShown then
        commands:show(true)
    end
end

function autohide:HandleCombatExited()
    self.cancelTimer = false
    C_Timer.After(NekometerConfig.autoHideDelay, function()
        if self.cancelTimer then
            self.cancelTimer = false
        elseif NekometerConfig.windowShown and self:shouldHide() then
            commands:show(false)
        end
    end)
end

function autohide:shouldHide()
    local hide = NekometerConfig.autoHide
    if NekometerConfig.autoHideDisabledInInstances then
        local inInstance, _ = IsInInstance()
        hide = hide and not inInstance
    end
    if NekometerConfig.autoHideDisabledInGroups then
        hide = hide and not IsInGroup()
    end
    return hide
end

nekometer.autohide = autohide
