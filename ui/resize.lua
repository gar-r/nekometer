local _, nekometer = ...

local mainFrame = nekometer.frames.main
local barContainer = nekometer.frames.barContainer

local resizer = CreateFrame("Button", nil, barContainer.frame)

function resizer:Init()
    self:SetSize(16, 16)
    self:SetPoint("BOTTOMRIGHT", barContainer.frame, "BOTTOMRIGHT", -2, 2)
    self:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    self:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self:SetShown(not NekometerConfig.windowLocked)
    self:SetScript("OnMouseDown", function(_, button)
        if not NekometerConfig.windowLocked and button == "LeftButton" then
            mainFrame:StartSizing("BOTTOMRIGHT")
        end
    end)
    self:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            mainFrame:StopMovingOrSizing()
            mainFrame:SaveLayout()
            barContainer:ScrollToTop()
        end
    end)
end

nekometer.frames.resizer = resizer