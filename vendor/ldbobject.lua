local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("databroker", ...) end

local DATAOBJECT_NAME = "Addon_"..AddonName

local ldb_plugin_definition = {
    type = "data source",
	text = L.ADDON_NAME,
    icon = "Interface\\Icons\\Achievement_Boss_Zuldazar_TreasureGolem",
    OnClick = function(clickedframe, button)
        Vendor.ShowRules()
    end,
}

local ldbplugin = nil
function Addon:GetOrCreateLDBPlugin()
    if ldbplugin then return ldbplugin end
    if not Addon:IsLDBAvailable() then return nil end
    ldbplugin = Addon:CreateLDBDataObject(DATAOBJECT_NAME, ldb_plugin_definition)
end

function Addon:UpdateLDBPlugin()
    -- updates the data in the object
end

local testmap = {}
testmap.hide = false

local minimapButton = nil
function Addon:GetOrCreateMinimapButton()
    if not Addon:IsLDBIconAvailable() then return nil end
    if minimapButton then return minimapButton end
    Addon:CreateLDBIcon(DATAOBJECT_NAME, testmap)
    minimapButton = Addon:GetLDBIconMinimapButton(DATAOBJECT_NAME)
end

-- Sets up all LDB plugins
function Addon:SetupLDBPlugins()
    --Addon:GetOrCreateLDBPlugin()
    --Addon:GetOrCreateMinimapButton()
end