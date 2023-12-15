local addonName, nekometer = ...

function nekometer:Init()
    nekometer.version = C_AddOns.GetAddOnMetadata(addonName, "Version")
end