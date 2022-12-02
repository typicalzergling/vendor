
local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("extensionmanager", ...) end

local ExtensionManager = Addon.Systems.ExtensionManager

local internalExtensions = {}

function ExtensionManager:GetAllAddonNamesForInternalExtensions()
    local list = {}
    for k, v in pairs(internalExtensions) do
        assert(v.addonName and type(k == "string"), "Name must exist")
        table.insert(list, v.addonName)
    end
    return list
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
        debugp("Extension for "..addonName.." already exists. Carrying on silently.")
        return true
    end

    local extension = {}
    extension.addonName = addonName
    extension.definition = extensionDefinition
    extension.enabled = false
    internalExtensions[addonName] = extension
    debugp("Added internal extension for: %s", addonName)
end

-- Register the extension for a particular addon.
function ExtensionManager:RegisterInternalExtension(addonName)
    assert(type(addonName) == "string", "Invalid input to RegisterInternalExtension: "..type(addonName))
    debugp("Attempting to register extension for %s", tostring(addonName))
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
    local addonInfo = {GetAddOnInfo(addonName)}
    -- 1 = name (folder)
    -- 2 = title
    -- 3 = description
    -- 4 = loadable
    -- 5 = reason (if 4 is false)
    -- 6 = security (always insecure)
    -- 7 = not used
    Addon:DebugForEach("extensionmanager", addonInfo)
    if not addonInfo[4] then
        debugp("Addon %s is not loadable, extension registration failed.", tostring(addonName))
        return false
    end

    -- Register the extension with Vendor
    debugp("About to register extension for  %s.", tostring(addonName))
    local success, result =  xpcall(Addon.RegisterExtension, CallErrorHandler, Addon, ext.definition)
    if not success then
        debugp("Registering with extension %s failed with %s", tostring(addonName), tostring(success))
        return false
    end

    -- Some extensions have bi-directional registration.
    if ext.definition.Register and type(ext.definition.Register) == "function" then
        success, result = xpcall(ext.definition.Register, CallErrorHandler, nil)
        if not success then
            debugp("Registering with extension %s failed with %s", tostring(addonName), tostring(success))
            return false
        else
            debugp("Register of extension succeeded with: %s", tostring(result))
        end
    end
    debugp("Extension registration with %s completed successfully.", tostring(addonName))
    return true
end
