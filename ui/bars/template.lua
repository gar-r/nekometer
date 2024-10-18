local _, nekometer = ...

local template = {
    LEFT = {
        {
            type = nekometer.bars.textWidget,
            selector = function(data)
                return data.name
            end,
            offset = 5,
            enabled = true,
        }
    },
    RIGHT = {
        {
            type = nekometer.bars.textWidget,
            selector = function(data)
                return AbbreviateNumbers(data.value)
            end,
            offset = -5,
            enabled = true,
        }
    },
}

function template:createWidgets(parent)
    local widgets = {}
    for _, align in ipairs({ "LEFT", "RIGHT" }) do
        local neighbor = parent
        for _, widgetDef in ipairs(self[align]) do
            if widgetDef.enabled then
                local widget = widgetDef.type:create({
                    widgetDef = widgetDef,
                    align = align,
                    parent = parent,
                    neighbor = neighbor,
                })
                table.insert(widgets, widget)
                neighbor = widget
            end
        end
    end
    return widgets
end

nekometer.bars = nekometer.bars or {}
nekometer.bars.template = template
