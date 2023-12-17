local _, nekometer = ...

local frame = CreateFrame("Frame", "NekometerChart", UIParent, "BasicFrameTemplate")
frame["text"] = "Nekometer"
frame:SetPoint("CENTER")
frame:SetSize(200, 200)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local bar = CreateFrame("StatusBar", nil, frame)
bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar:SetStatusBarColor(0, 1, 0)
bar:SetSize(195, 20)
bar:SetPoint("TOP", 0, -20)

local bar2 = CreateFrame("StatusBar", nil, frame)
bar2:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar2:SetStatusBarColor(1, 0, 0)
bar2:SetSize(195, 20)
bar2:SetPoint("TOP", 0, -40)

local bar3 = CreateFrame("StatusBar", nil, frame)
bar3:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar3:SetStatusBarColor(0, 0, 1)
bar3:SetSize(195, 20)
bar3:SetPoint("TOP", 0, -60)

frame:Show()

nekometer.frames.chart = frame
