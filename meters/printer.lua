local _, nekometer = ...

local printer = {}

function printer:Accept(data)
    local msg = string.format("%s damages %s with %s for %s",
        data.sourceName,
        data.destName,
        data.ability,
        data.amount)
    print(msg)
end

nekometer.printer = printer
