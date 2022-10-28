local AddonName, Addon = ...
local L = Addon:GetLocale()

local LdbFeature = {
    NAME = "LibDataBroker - Source",
    STATE = "preview",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

local function debug(message, ...) 
    Addon:Debug("databroker", message, ...)
end

--  1 = total count
--  2 = sell value
--  3 = sell count
--  4 = delete count
--  5 = sell items
--  6 = delete items
local stats = { 0, 0, 0, 0, {}, {} }

local DATAOBJECT_NAME = AddonName
local ldb_plugin_definition = 
{
    type = "data source",
    text = "",
	label = L.ADDON_NAME,
    icon = "Interface\\Icons\\Achievement_Boss_Zuldazar_TreasureGolem",

    OnClick = function(self, button)
        Vendor.ShowRules()
    end,

    -- called to show the tooltip
    OnTooltipShow = function(tooltip)
        stats = { Vendor.GetEvaluationStatus() }

        if (stats[1] ~= 0) then
            tooltip:AddLine(L.LDB_BUTTON_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            tooltip:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_VALUE, Addon:GetPriceString(stats[2]))

            if (stats[3] ~= 0) then
                tooltip:AddLine(" ")
                tooltip:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TOSELL, tostring(stats[3]))
                tooltip:AddLine("    "..table.concat(stats[5], "\n    "))
            end

            if (stats[4] ~= 0) then
                tooltip:AddLine(" ")
                tooltip:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TODESTROY, tostring(stats[4]))
                tooltip:AddLine("    "..table.concat(stats[6], "\n    "))
            end
        else
            tooltip:AddLine("There is nothing to vendor or delete")            
        end
    end,
}

function LdbFeature:CreateLDBPlugin()
    self.plugin = Addon:CreateLDBDataObject(DATAOBJECT_NAME, ldb_plugin_definition)
end

function LdbFeature:CreateMinimapButton()
    if (Addon:IsLDBIconAvailable()) then
        self.minimap_data = { hide = false }
        Addon:CreateLDBIcon(DATAOBJECT_NAME, self.minimap_data)
        self.minimap = Addon:GetLDBIconMinimapButton(DATAOBJECT_NAME)
    end
end

function LdbFeature:UpdateLDBPlugin()
    if (self.plugin) then
        debug("Updating LDB plugin text")
        stats = { Vendor.GetEvaluationStatus() }
        self.plugin.text = string.format("%s%d|r %s", HIGHLIGHT_FONT_COLOR_CODE, stats[0], Addon:GetPriceString(stats[2]))
        debug("Updated text :: %s", self.plugin.text)
    end
end

function LdbFeature:OnInitialize()
    if (Addon:IsLDBAvailable()) then
        debug("Initializing LDB objects")
        self:CreateLDBPlugin()
        self:CreateMinimapButton()
        self:UpdateLDBPlugin()
    end

    return true;
end

function LdbFeature:OnTerminate()
    self.plugin = nil
    self.minimap = nil
end

function LdbFeature:ON_BAG_UPDATE()
    self:UpdateLDBPlugin();
end

function LdbFeature:ON_PLAYER_ENTERING_WORLD()
    self:UpdateLDBPlugin();
end

function LdbFeature:OnProfileChanged()
    self:UpdateLDBPlugin();
end

Addon.Features = Addon.Features or {}
Addon.Features.LdbFeature = LdbFeature
