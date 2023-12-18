local _, nekometer = ...

local meter = {}

function meter:Accept(e)
    local msg = string.format("%s %ss %s with %s for %d",
        e.sourceName,
        e.type,
        e.destName,
        e.ability,
        e.amount)
    print(msg)
end

nekometer.printer = meter
