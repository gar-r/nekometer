local _, nekometer = ...

local specs = {
    pendingInspect = {},
    inProgress = nil,
}

function specs:GetSpecializationByID(id)
    if self.pendingInspect[id] then
        return
    end
    local unit = self:getUnit(id)
    if not unit then
        return
    end
    self:pushPending(id, unit)
    if not self.inProgress then
        self:InspectNext()
    end
end

function specs:InspectNext()
    local item = self:popPending()
    if item then
        self.inProgress = item
        NotifyInspect(item.unit)
        C_Timer.After(3, function()
            -- if the inspect hasn't completed in 3 seconds, we'll just move on;
            -- this can happen if the api is rate limited
            if self.inProgress == item then
                self.inProgress = nil
                self:InspectNext()
            end
        end)
    end
end

function specs:HandleInspectReady(id)
    local item = self.inProgress
    if item == nil or id ~= item.id then
        return -- different unit, ignore
    end
    local icon = self:getSpecIcon(item.unit)
    if icon then
        nekometer.classIcons:Set(item.id, icon)
    end
    self.inProgress = nil
    ClearInspectPlayer()
    self:InspectNext()
end

function specs:getSpecIcon(unit)
    local specID = GetInspectSpecialization(unit)
    if specID == 0 then
        return nil
    end
    local _, _, _, icon = GetSpecializationInfoByID(specID)
    return icon
end

function specs:getUnit(id)
    if UnitGUID("player") == id then
        return "player"
    end
    local groupSize = GetNumGroupMembers()
    for i = 1, groupSize do
        local unit = IsInRaid() and "raid" .. i or "party" .. i
        if UnitGUID(unit) == id then
            return unit
        end
    end
end

function specs:pushPending(id, unit)
    self.pendingInspect[id] = unit
    table.insert(self.pendingInspect, {
        id = id,
        unit = unit
    })
end

function specs:popPending()
    local item = table.remove(self.pendingInspect)
    if item then
        self.pendingInspect[item.id] = nil
    end
    return item
end

nekometer.specs = specs
