local addonName, nekometer = ...

local config = nekometer.config
local dispatcher = nekometer.dispatcher

---@class Frame
local frame = CreateFrame("Frame", "NekometerMain")

function frame:OnEvent(event, ...)
    self[event](self, event, ...)
end

function frame:ADDON_LOADED(_, name)
    if name == addonName then
        config:Init()
        nekometer.enabledMeters = {}
        for _, cfg in ipairs(config.meters) do
            if cfg.enabled then
                local meter = nekometer.meters[cfg.key]
                dispatcher:AddMeter(meter, cfg)
                table.insert(nekometer.enabledMeters, meter)
            end
        end
    end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
    dispatcher:HandleCombatEvent()
end

function frame:PLAYER_REGEN_DISABLED()
    dispatcher:CombatEntered()
end

function frame:PLAYER_REGEN_ENABLED()
    dispatcher:CombatExited()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", frame.OnEvent)
