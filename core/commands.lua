SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local _, nekometer = ...

local commands = {}

function commands:config(_)
    Settings.OpenToCategory("Nekometer")
end

function commands:wipe(_)
    nekometer.wipe()
end

function commands:reset(_)
    StaticPopup_Show("NEKOMETER_RESET")
end

function commands:toggle(_)
    local shown = not NekometerConfig.window.shown
    NekometerConfig.window.shown = shown
    local main = nekometer.frames.main
    if main then
        main:SetShown(shown)
    end
end

function commands:report(msg)
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