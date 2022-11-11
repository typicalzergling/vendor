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
    if minimapButton then return end
    local ldb = Addon:GetFeature("LibDataBroker")
    if not ldb or not ldb:IsLDBIconAvailable() then
        debugp("LDBIcon is not available.")
        return false
    end

    local ldbstatusplugin = Addon:GetFeature("LDBStatusPlugin")
    if not ldbstatusplugin then
        debugp("LDBStatusPlugin is not available.")
        return false
    end
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


local function updateButtonState()
    debugp("Updating button state")
end

-- Called whenever profiles change
-- This is ANY setting changed.
function MinimapButton:OnProfileChanged()
    updateButtonState()
end


Addon.Features.MinimapButton = MinimapButton