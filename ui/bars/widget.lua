local _, nekometer = ...

local util = {}

local text = {}

function text:create(info)
    local fs = info.parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local color = NekometerConfig.barTextColor
    fs:SetTextColor(color.r, color.g, color.b)
    local relativeAlign = util:getRelativeAlign(info)
    fs:SetPoint(info.align, info.neighbor, relativeAlign, info.widgetDef.offset, 0)
    return {
        frame = fs,
        update = function(data)
            local val = info.widgetDef.selector(data)
            fs:SetText(val)
        end
    }
end

function util:getRelativeAlign(info)
    if info.parent == info.neighbor then
        return info.align
    end
    if info.align == "LEFT" then
        return "RIGHT"
    end
    return "LEFT"
end

nekometer.bars = nekometer.bars or {}
nekometer.bars.textWidget = text