SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local addonName, nekometer = ...

local commands = {}

function commands:config(_)
    Settings.OpenToCategory(addonName)
end

function commands:wipe(_)
    nekometer.wipe()
end

function commands:reset(_)
    StaticPopup_Show("NEKOMETER_RESET")
end

function commands:toggle(_)
    local shown = not NekometerConfig.windowShown
    NekometerConfig.windowShown = shown
    self:show(shown)
end

function commands:show(shown)
    local main = nekometer.frames.main
    if main then
        main:SetShown(shown)
    end
end

function commands:center(_)
    local main = nekometer.frames.main
    if main then
        main:ClearAllPoints()
        main:SetPoint("CENTER")
        main:SetShown(true)
    end
end

function commands:report(_)
    local frame = nekometer.frames.main
    if frame then
        local meter = frame:GetCurrentMeter()
        if meter.Report then
            nekometer.PrintReport(meter:Report())
        end
    end
end

local function SlashCommandHandler(msg, _)
    local verb, args = msg:match("^(%S*)%s*(.-)$")
    local cmd = commands.toggle
    if verb and commands[verb] then
        cmd = commands[verb]
    end
    cmd(commands, args)
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler

nekometer.commands = commands
