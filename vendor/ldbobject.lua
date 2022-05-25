local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("databroker", ...) end

local ldbplugin = nil

local totalCount = 0
local sellValue = 0
local sellCount = 0
local deleteCount = 0
local totalCountStr = ""
local sellCountStr = ""
local sellValueStr = ""
local deleteCountStr = ""
local sellItems = {}
local deleteItems = {}
local function updateStats()
    totalCount, sellValue, sellCount, deleteCount, sellItems, deleteItems = Vendor.GetEvaluationStatus()
    totalCountStr = tostring(totalCount)
    sellCountStr = tostring(sellCount)
    deleteCountStr = tostring(deleteCount)
    sellValueStr = Addon:GetPriceString(sellValue)

    if ldbplugin then
        ldbplugin.text = HIGHLIGHT_FONT_COLOR_CODE .. totalCountStr .. FONT_COLOR_CODE_CLOSE .. "  " .. sellValueStr
    end
end

local DATAOBJECT_NAME = AddonName
local ldb_plugin_definition = {
    type = "data source",
    text = "",
	label = L.ADDON_NAME,
    icon = "Interface\\Icons\\Achievement_Boss_Zuldazar_TreasureGolem",
    OnClick = function(self, button)
        Vendor.ShowRules()
    end,
    OnTooltipShow = function(self)
        -- Dirty hack until we have all events covered.
        updateStats()
        self:AddLine(L.LDB_BUTTON_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_VALUE, sellValueStr)
        self:AddLine(" ")
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TOSELL, sellCountStr)
        self:AddLine("    "..table.concat(sellItems, "\n    "))
        self:AddLine(" ")
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TODESTROY, deleteCountStr)
        self:AddLine("    "..table.concat(deleteItems, "\n    "))
    end,
}

function Addon:GetOrCreateLDBPlugin()
    if ldbplugin then return ldbplugin end
    if not Addon:IsLDBAvailable() then return nil end
    ldbplugin = Addon:CreateLDBDataObject(DATAOBJECT_NAME, ldb_plugin_definition)
end

function Addon:UpdateLDBPlugin()
    updateStats()
end

-- Sets up all LDB plugins
function Addon:SetupLDBPlugin()
    Addon:GetOrCreateLDBPlugin()
    Addon:GetOrCreateMinimapButton()
    Addon:RegisterEvent("BAG_UPDATE", "UpdateLDBPlugin")
    Addon:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateLDBPlugin")
    Addon:GetProfileManager():RegisterCallback("OnProfileChanged", Addon.UpdateLDBPlugin, self);
end

-- Hacky way to do minimap icon. Should move this someplace else and clean it up.

local testmap = {}
testmap.hide = false

local minimapButton = nil
function Addon:GetOrCreateMinimapButton()
    if not Addon:IsLDBIconAvailable() then return nil end
    if minimapButton then return minimapButton end
    Addon:CreateLDBIcon(DATAOBJECT_NAME, testmap)
    minimapButton = Addon:GetLDBIconMinimapButton(DATAOBJECT_NAME)
end
