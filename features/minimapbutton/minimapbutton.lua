local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("minimapbutton", ...) end

-- Feature Definition
local MinimapButton = {
    NAME = "MinimapButton",
    VERSION = 1,
    DEPENDENCIES = {
        "LibDataBroker",
        "LDBStatusPlugin",
    },
}

local minimapButton = nil

-- Once you have the minimap object you can call methods like:
-- Show()
-- Hide()
-- Lock()
-- Unlock()
function MinimapButton:Get()
    return minimapButton
end

-- Hacky way to do minimap icon. Need to add settings to save the location
local testmap = {}
testmap.hide = false
function MinimapButton:Create()
    -- Ensure idempotency - if this is already created we have nothing to create.
    if minimapButton then
        -- If this is already created we will assume someone explicitly called to enable this again
        -- In this case, it is a safe assumption they would like us to show the minimap button.
        minimapButton:Show()
        return true
    end

    -- We depend on LibDataBroker for this and the LDBIcon library.
    local ldb = Addon:GetFeature("LibDataBroker")
    if not ldb or not ldb:IsLDBIconAvailable() then
        debugp("LDBIcon is not available.")
        return false
    end

    -- We also require the LDBStatusPlugin to be enabled.
    local ldbstatusplugin = Addon:GetFeature("LDBStatusPlugin")
    if not ldbstatusplugin then
        debugp("LDBStatusPlugin is not available.")
        return false
    end

    -- Create the minimap button.
    minimapButton = ldb:CreateLDBIcon(ldbstatusplugin:GetDataObjectName(), testmap)
    return not not minimapButton
end

function MinimapButton:OnInitialize()
    debugp("Initializing")
    local created = self:Create()
    if not created then
        debugp("Failed to create LDBIcon")
        return
    end

    debugp("Initialize Complete")
end

function MinimapButton:OnTerminate()
    debugp("Terminating")
    -- Since all this feature does is display a button that uses LDBStatusPlugin, there is nothing
    -- to do to "terminate" this feature beyond hiding the button. It will still be around, but
    -- trying to remove it is potentially messy and it doesn't do anything. On next reload since
    -- the feature is disabled it will not load in the first place so this is a temporary condition.
    if minimapButton then
        minimapButton:Hide()
    end
    debugp("Terminate Complete")
end


local function updateButtonState()
    debugp("Updating button state")
end

-- Called whenever profiles change
-- This is ANY setting changed.
function MinimapButton:OnProfileChanged()
    updateButtonState()
end


Addon.Features.MinimapButton = MinimapButton