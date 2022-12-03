--[[
    Info System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("extensionmanager", ...) end

local ExtensionManager = {}

function ExtensionManager:GetDependencies()
    return {
        "info",
        "rules",
        "interop",
        "lists",
    }
end

function ExtensionManager:Startup(onready)

    -- Load all extensions for addons which may have already been loaded prior to our addon loading.
    debugp("In ExtensionManager Startup")
    local extensions = self:GetAllAddonNamesForInternalExtensions()
    debugp("Extension table: %s", tostring(#extensions))
    for i, v in pairs(extensions) do
        debugp("Value = %s", tostring(v))
        self:RegisterInternalExtension(v)
    end

    -- Register event to handle addons which load after we do.
    --Addon:RegisterEvent("ADDON_LOADED", self.OnAddonLoaded)

    onready({
        -- Eventually add external extension registration here when it is migrated.
        })
end

function ExtensionManager:Shutdown()
end

-- For addons that load after we do, if one of them is an internal extension, register it.
function ExtensionManager.ON_ADDON_LOADED(addonName)
    if ExtensionManager:GetInternalExtension(addonName) then
        ExtensionManager:RegisterInternalExtension(addonName)
    end
end


Addon.Systems.ExtensionManager = ExtensionManager