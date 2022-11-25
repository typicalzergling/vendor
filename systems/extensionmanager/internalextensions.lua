
local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("extensionmanager", ...) end

local ExtensionManager = Addon.Systems.ExtensionManager

local internalExtensions = {}

function ExtensionManager:GetAllInternalExtensions()
    return internalExtensions
end

function ExtensionManager:GetInternalExtension(addonName)
    if internalExtensions[addonName] then
        return internalExtensions[addonName]
    else
        return nil
    end
end

-- Adds extension definition that will be loaded if addonName is present.
function ExtensionManager:AddInternalExtension(addonName, extensionDefinition)
    if internalExtensions[addonName] then
        error("Extension for "..addonName.." already exists. Use that one.")
    end

    local extension = {}
    extension.addonName = addonName
    extension.definition = extensionDefinition
    extension.enabled = false
    table.insert(internalExtensions, extension)
end

-- Register the extension for a particular addon.
function ExtensionManager:RegisterInternalExtension(addonName)
    assert(type(addonName) == "string", "Invalid input to RegisterInternalExtension: "..type(addonName))
    local ext = internalExtensions[addonName]
    if not ext then
        debugp("Attempted to register an extension for %s, which does not exist.", addonName)
        return false
    end

    -- Ensure valid definition these will be stripped out of release.
    assert(ext.addonName, "Invalid extension definition; missing key 'addonName'")
    assert(ext.definition and type(ext.definition == "table"), "Invalid extension definition; missing or invalid 'definition'")
    assert(type(ext.enabled) == "boolean", "Invalid extension definition; invalid type for 'enabled'")

    -- For idempotency we shall not error here, just do nothing.
    if ext.enabled then
        debugp("Extension is already registered for %s", addonName)
        return true
    end

    -- Verify the Addon is actually present
    if not _G[addonName] then
        debugp("Addon %s is not present yet, extension registration failed.")
        return false
    end

    -- Register the extension
    return true

end
