local _, nekometer = ...

local barTemplate = {
    LEFT = {
        {
            type = "text",
            offset = 0,
            updateFn = function(self, data)
                self:SetText("1. ")
            end,
        },
        {
            type = "text",
            offset = 5,
            updateFn = function(self, data)
                self:SetText(data.name)
            end,
        }
    },
    RIGHT = {
        {
            type = "text",
            offset = -5,
            updateFn = function(self, data)
                self:SetText(AbbreviateNumbers(data.value))
            end,
        }
    },
}

function barTemplate:createWidgets(parent)
    local widgets = {}
    for _, align in ipairs({ "LEFT", "RIGHT" }) do
        local neighbor = parent
        for _, widgetDef in ipairs(self[align]) do
            local widget = self:createWidget({
                widgetDef = widgetDef,
                align = align,
                parent = parent,
                neighbor = neighbor,
            })
            table.insert(widgets, widget)
            neighbor = widget
        end
    end
    return widgets
end

function barTemplate:createWidget(info)
    local fontString = info.parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local color = NekometerConfig.barTextColor
    fontString:SetTextColor(color.r, color.g, color.b)
    local relativeAlign = self:getRelativeAlign(info)
    fontString:SetPoint(info.align, info.neighbor, relativeAlign, info.widgetDef.offset, 0)
    fontString.update = info.widgetDef.updateFn
    return fontString
end

function barTemplate:getRelativeAlign(info)
    if info.parent == info.neighbor then
        return info.align
    end
    if info.align == "LEFT" then
        return "RIGHT"
    end
    return "LEFT"
end

nekometer.frames.barTemplate = barTemplate
