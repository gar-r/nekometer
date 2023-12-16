local _, nekometer = ...

local printer = {}

function printer:Accept(e)
    local msg = string.format("%s damages %s with %s for %s",
        e.sourceName,
        e.destName,
        e.ability,
        e.amount)
    print(msg)
end

nekometer.printer = printer
