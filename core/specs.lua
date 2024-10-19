local _, nekometer = ...

local specs = {
    inProgress = {},
}

function specs:HandleInspectReady(id)
    local unit = self.inProgress[id]
    if not unit then
        return
    end
    local icon = self:getSpecIcon(unit)
    nekometer.classIcons:Set(id, icon)
    self.inProgress[id] = nil
end

function specs:GetSpecializationByID(id)
    local unit = specs:getUnit(id)
    if not unit
        or not CanInspect(unit)
        or self.inProgress[id]
    then
        return
    end
    NotifyInspect(unit)
    self.inProgress[id] = unit
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

nekometer.specs = specs
