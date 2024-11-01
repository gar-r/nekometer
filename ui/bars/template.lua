local _, nekometer = ...

local main = nekometer.frames.main
local util = nekometer.util

local template = {
    LEFT = {
        {
            type = nekometer.bars.iconWidget,
            selector = function(data)
                local meter = main:GetCurrentMeter()
                if meter.reportsAbilities then
                    return nekometer.abilityIcons:Lookup(data.id)
                else
                    local icon = nekometer.classIcons:Lookup(data.id)
                    if icon ~= nil then
                        return icon
                    end
                    -- spec icon not loaded yet, fallback to the base icon
                    local class = nekometer.classes:Lookup(data.id)
                    if class then
                        return util:GetClassTexture(class)
                    end
                end
            end,
            offset = 0,
            config = "barIconsDisplayEnabled",
        },
        {
            type = nekometer.bars.textWidget,
            selector = function(data)
                return data.position .. ". "
            end,
            offset = 3,
            config = "barPositionDisplayEnabled",
        },
        {
            type = nekometer.bars.textWidget,
            selector = function(data)
                return data.name
            end,
            offset = 5,
        }
    },
    RIGHT = {
        {
            type = nekometer.bars.textWidget,
            selector = function(data)
                return AbbreviateNumbers(data.value)
            end,
            offset = -5,
        }
    },
}

function template:createWidgets(parent)
    local widgets = {}
    for _, align in ipairs({ "LEFT", "RIGHT" }) do
        local neighbor = parent
        for _, widgetDef in ipairs(self[align]) do
            if self:isWidgetEnabled(widgetDef) then
                local widget = widgetDef.type:create({
                    widgetDef = widgetDef,
                    align = align,
                    parent = parent,
                    neighbor = neighbor,
                })
                table.insert(widgets, widget)
                neighbor = widget.frame
            end
        end
    end
    return widgets
end

function template:isWidgetEnabled(widgetDef)
    return not widgetDef.config or NekometerConfig[widgetDef.config]
end

nekometer.bars = nekometer.bars or {}
nekometer.bars.template = template
