local _, nekometer = ...

local meter = {
    title = "Dps",
    current = nekometer.aggregator:new(),
    total = {
        data = {},
        duration = 0,
    },
}

function meter:CombatEvent(e)
    if e:IsDamage() or e:IsSpellReflect() then
        local source = e:GetSource()
        local amount = e:GetAmount()
        self.current:Add({
            key = source.id,
            name = source.name,
            value = amount,
        })
    end
end

function meter:CombatEntered()
    self:ResetCurrent()
    self.combatStart = GetTime() -- order matters
end

function meter:CombatExited()
    self.combatEnd = GetTime()
    local segment = self:GetCurrentSegment()
    self:mergeSegment(segment, self.total)
end

function meter:Report()
    local segment = self:GetCurrentSegment()
    local mode = nekometer.getMode(self.key)
    if mode == "total" then
        self:mergeSegment(self.total, segment)
    end
    return nekometer.CreateReport(segment.data, self)
end

function meter:GetCurrentSegment()
    if not self.combatStart then
        -- no combat since start
        return {
            data = {},
            duration = 0,
        }
    end
    local duration
    if self.combatEnd then
        duration = self.combatEnd - self.combatStart
    else
        -- still in combat, so we use the current time
        duration = GetTime() - self.combatStart
    end
    local dps = {}
    local data = self.current:GetData()
    for k, v in pairs(data) do
        dps[k] = {
            key = v.key,
            name = v.name,
            value = math.floor(v.value / duration)
        }
    end
    return {
        data = dps,
        duration = duration,
    }
end

function meter:Reset()
    self.total = {
        data = {},
        duration = 0,
    }
    self:ResetCurrent()
end

function meter:ResetCurrent()
    self.current:Clear()
    if self.combatStart and not self.combatEnd then
        self.combatStart = GetTime()
    else
        self.combatStart = nil
    end
    self.combatEnd = nil
end

--[[ Merge source segment data into target segment in proportion to their durations. ]]
function meter:mergeSegment(source, target)
    local sourceWeight = source.duration / (source.duration + target.duration)
    local targetWeight = 1 - sourceWeight
    local sourceData = source.data
    local targetData = target.data
    for k, v in pairs(sourceData) do
        if targetData[k] then
            targetData[k].value = targetData[k].value * targetWeight + v.value * sourceWeight
        else
            targetData[k] = v
            targetData[k].value = targetData[k].value * sourceWeight
        end
    end
    target.duration = target.duration + source.duration
end

nekometer.meters = nekometer.meters or {}
nekometer.meters.dps = meter
