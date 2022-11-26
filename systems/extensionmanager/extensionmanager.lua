--[[
    Info System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("extensionmanager", ...) end

local ExtensionManager = {}

function ExtensionManager:GetDependencies()
    return {
        "info",
        "rules",
        "interop",
        "lists",
    }
end

function ExtensionManager:Startup()

    -- Load all extensions for addons which may have already been loaded prior to our addon loading.
    debugp("In ExtensionManager Startup")
    local extensions = self:GetAllAddonNamesForInternalExtensions()
    debugp("Extension table: %s", tostring(#extensions))
    for i, v in pairs(extensions) do
        debugp("Value = %s", tostring(v))
        self:RegisterInternalExtension(v)
    end

    -- Register event to handle addons which load after we do.
    Addon:RegisterEvent("ADDON_LOADED", self.OnAddonLoaded)

    return {
        -- Eventually add external extension registration here when it is migrated.
    }
end

function ExtensionManager:Shutdown()
end


function ExtensionManager.OnAddonLoaded(addonName)
end


Addon.Systems.ExtensionManager = ExtensionManager