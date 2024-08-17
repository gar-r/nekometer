local _, nekometer = ...

local mainFrame = nekometer.frames.main
local bars = nekometer.frames.bars

local resizer = CreateFrame("Button", nil, mainFrame)

function resizer:Init()
    self:SetSize(16, 16)
    self:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -2, 2)
    self:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    self:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            mainFrame:StartSizing("BOTTOMRIGHT")
        end
    end)
    self:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            mainFrame:StopMovingOrSizing()
            bars:ScrollToTop()
        end
    end)
end

nekometer.frames.resizer = resizer