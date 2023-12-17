local _, nekometer = ...

local frame = CreateFrame("Frame", "NekometerChart", UIParent, "BasicFrameTemplate")
frame:SetPoint("CENTER")
frame:SetSize(200, 200)
-- frame:SetBackdrop(BACKDROP_TUTORIAL_16_16)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame:Show()

nekometer.frames.chart = frame