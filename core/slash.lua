SLASH_NEKOMETER1 = "/nm"
SLASH_NEKOMETER2 = "/nekometer"

local _, nekometer = ...

local commands = {}

function commands:config(_)
    InterfaceOptionsFrame_OpenToCategory(nekometer.frames.config)
end

function commands:reset(_)
    StaticPopup_Show("NEKOMETER_RESET")
end

function commands:report(msg)
    local meter = nekometer.damage
    if msg and nekometer[msg] and nekometer[msg].Report then
        meter = nekometer[msg]
    end
    nekometer.PrintReport(meter:Report())
end

local function SlashCommandHandler(msg, _)
    local verb, args = msg:match("^(%S*)%s*(.-)$")
    local cmd = commands.config
    if verb and commands[verb] then
        cmd = commands[verb]
    end
    cmd(commands, args)
end

SlashCmdList["NEKOMETER"] = SlashCommandHandler