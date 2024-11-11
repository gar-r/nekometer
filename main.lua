local addonName, nekometer = ...

local dispatcher = nekometer.dispatcher
local autohide = nekometer.autohide
local autoreset = nekometer.autoreset
local specs = nekometer.specs

---@class Frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:initConfig()
    nekometer.init()
end

function frame:initMeters()
    nekometer.enabledMeters = {}
    for _, key in ipairs(nekometer.meters) do
        if nekometer.isMeterEnabled(key) then
            local meter = nekometer.meters[key]
            if meter then
                meter.key = key
                dispatcher:AddMeter(meter, NekometerConfig)
                table.insert(nekometer.enabledMeters, meter)
            end
        end
    end
end

function frame:initFrames()
    for _, f in pairs(nekometer.frames) do
        if f.Init then
            f:Init()
        end
    end
end

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        self:initConfig()
        self:initMeters()
        self:initFrames()
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    dispatcher:HandleCombatEvent()
end

function frame:PLAYER_REGEN_DISABLED()
    autohide:HandleCombatEntered()
    dispatcher:HandleCombatEntered()
end

function frame:PLAYER_REGEN_ENABLED()
    autohide:HandleCombatExited()
    dispatcher:HandleCombatExited()
end

function frame:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
    if isLogin or isReload then
        return
    else
        autoreset:HandleZoneChange()
    end
end

function frame:WALK_IN_DATA_UPDATE()
    autoreset:HandleDelveUpdate()
end

function frame:INSPECT_READY(_, inspectee)
    specs:HandleInspectReady(inspectee)
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("WALK_IN_DATA_UPDATE")
frame:RegisterEvent("INSPECT_READY")
frame:SetScript("OnEvent", frame.OnEvent)
