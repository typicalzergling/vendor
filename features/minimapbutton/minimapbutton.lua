local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("minimapbutton", ...) end

-- Feature Definition
local MinimapButton = {
    NAME = "MinimapButton",
    VERSION = 1,
    -- you can also use GetDependencies
    DEPENDENCIES = {
        "LibDataBroker",
        "LDBStatusPlugin",
    },
}

-- Default minimap state and position
local mapdefault = {
    hide = false,
    minimapPos = 225
}

-- Used for tracking the actual data.
local profilemapdata = nil
local minimapButton = nil

function MinimapButton:Get()
    return minimapButton
end

local function updateButtonVisibility()
    debugp("Updating button visibility")
    local enabled = Addon:GetProfile():GetValue(Addon.c_Config_MinimapButton)
    if enabled then
        minimapButton:Show()
    else
        minimapButton:Hide()
    end
end

local function updateButtonPosition()
    debugp("Updating button position")
    local ldb = Addon:GetFeature("LibDataBroker")
    if not ldb or not ldb:IsLDBIconAvailable() then
        debugp("LDBIcon is not available.")
        return false
    end

    -- we need to update the button's position to the current profile setting.
    profilemapdata = Addon:GetAccountSetting(Addon.c_Config_MinimapData, mapdefault)
    local success = ldb:SetButtonToPosition(minimapButton, profilemapdata.minimapPos)
    debugp("Button position updated: %s", not not success)
end

local function savePositionToProfile()
    debugp("Saving button position")
    Addon:SetAccountSetting(Addon.c_Config_MinimapData, profilemapdata)
end

function MinimapButton:Create()
    -- Ensure idempotency - if this is already created we have nothing to create.
    if minimapButton then
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

    -- Get minimap data from profile
    profilemapdata = Addon:GetAccountSetting(Addon.c_Config_MinimapData, mapdefault)

    -- Create the minimap button.
    minimapButton = ldb:CreateLDBIcon(ldbstatusplugin:GetDataObjectName(), profilemapdata)
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
    savePositionToProfile()
end

function MinimapButton:OnAccountSettingChange(settings)
    if (settings[Addon.c_Config_MinimapData]) then
        updateButtonPosition()
        updateButtonVisibility()
    end
end

Addon.Features.MinimapButton = MinimapButton