local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("items", ...) end

local ItemProperties = {}

--[[ Retrieve our depenedencies ]]
function ItemProperties:GetDependencies()
    return { "info", "savedvariables", "profile" }
end

--[[ Startup our system ]]
function ItemProperties:Startup()
    return {
        "GetPropertyDocumentation",
        "GetPropertyList",
        "GetPropertyType",
        "GetPropertyDefault",
        "IsPropertyHidden",
        }
end

--[[ Shutdown our system ]]
function ItemProperties:Shutdown()
end

Addon.Systems.ItemProperties = ItemProperties
