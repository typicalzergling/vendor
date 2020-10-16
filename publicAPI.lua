-- Public API 
-- All methods exposed and intended for use by other addons or scripts are here.
local _, Addon = ...
local L = Addon:GetLocale()

assert(Addon.Public, "Public not defined. This is a programmer error in load order.")


Addon:MakePublic(
    "RegisterExtension",
    function (extension) return Addon:RegisterExtension(extension) end,
    L["API_REGISTEREXTENSION_TITLE"],
    L["API_REGISTEREXTENSION_DOCS"])

Addon:MakePublic(
    "EvaluateItem",
    function (arg1, arg2)
        local item = Addon:GetItemProperties(arg1, arg2)
        if item then
            return Addon:EvaluateItemForSelling(item)
        end
        return nil
    end,
    L["API_EVALUATEITEM_TITLE"],
    L["API_EVALUATEITEM_DOCS"])

Addon:MakePublic(
    "AddTooltipItemToAlwaysSellList",
    function () Addon:AddTooltipItemToAlwaysSellList() end,
    L["API_ADDTOALWAYSSELL_TITLE"],
    L["API_ADDTOALWAYSSELL_DOCS"])
    
Addon:MakePublic(
    "AddTooltipItemToNeverSellList",
    function () Addon:AddTooltipItemToNeverSellList() end,
    L["API_ADDTONEVERSELL_TITLE"],
    L["API_ADDTONEVERSELL_DOCS"])
    
Addon:MakePublic(
    "AutoSell",
    function () Addon:AutoSell_Cmd() end,
    L["API_AUTOSELL_TITLE"],
    L["API_AUTOSELL_DOCS"])

Addon:MakePublic(
    "ShowSettings",
    function () Addon:OpenSettings_Cmd() end,
    L["API_OPENSETTINGS_TITLE"],
    L["API_OPENSETTINGS_DOCS"])

Addon:MakePublic(
    "ShowKeybindings",
    function () Addon:OpenKeybindings_Cmd() end,
    L["API_OPENKEYBINDINGS_TITLE"],
    L["API_OPENKEYBINDINGS_DOCS"])

Addon:MakePublic(
    "ShowRules",
    function () VendorRulesDialog:Toggle() end,
    L["API_OPENRULES_TITLE"],
    L["API_OPENRULES_DOCS"])

Addon:MakePublic(
    "GetStats",
    function () return Addon:GetStats() end,
    L["API_GETSTATS_TITLE"],
    L["API_GETSTATS_DOCS"])

Addon:MakePublic(
    "GetPriceString",
    function (price) return Addon:GetPriceString(price) end,
    L["API_GETPRICESTRING_TITLE"],
    L["API_GETPRICESTRING_DOCS"])


