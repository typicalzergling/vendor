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
    function (bag, slot) return Addon:EvaluateSource(bag, slot) end,
    L["API_EVALUATEITEM_TITLE"],
    L["API_EVALUATEITEM_DOCS"])

Addon:MakePublic(
    "AddTooltipItemToSellList",
    function () Addon:AddTooltipItemToSellList() end,
    L["API_ADDTOALWAYSSELL_TITLE"],
    L["API_ADDTOALWAYSSELL_DOCS"])
    
Addon:MakePublic(
    "AddTooltipItemToKeepList",
    function () Addon:AddTooltipItemToKeepList() end,
    L["API_ADDTONEVERSELL_TITLE"],
    L["API_ADDTONEVERSELL_DOCS"])

Addon:MakePublic(
    "AddTooltipItemToDestroyList",
    function () Addon:AddTooltipItemToDestroyList() end,
    L["API_ADDTODESTROY_TITLE"],
    L["API_ADDTODESTROY_DOCS"])
    
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
    function () 
        Addon:OpenKeybindings_Cmd()
    end,
    L["API_OPENKEYBINDINGS_TITLE"],
    L["API_OPENKEYBINDINGS_DOCS"])

Addon:MakePublic(
    "ShowRules",
    function ()
        Addon:WithFeature("Vendor", function(vendor)
            vendor:ShowDialog("rules")
        end)
    end,
    L["API_OPENRULES_TITLE"],
    L["API_OPENRULES_DOCS"])

Addon:MakePublic(
    "ShowProfiles",
    function ()
        Addon:WithFeature("Vendor", function(vendor)
            vendor:ShowDialog("profiles")
        end)
    end,
    L["API_OPENPROFILES_TITLE"],
    L["API_OPENPROFILES_DOCS"])

Addon:MakePublic(
    "GetEvaluationStatus",
    function ()
        return Addon:GetEvaluationStatus()
    end,
    L["API_GETEVALUATIONSTATUS_TITLE"],
    L["API_GETEVALUATIONSTATUS_DOCS"])

Addon:MakePublic(
    "GetPriceString",
    function (price) return Addon:GetPriceString(price) end,
    L["API_GETPRICESTRING_TITLE"],
    L["API_GETPRICESTRING_DOCS"])

Addon:MakePublic(
    "GetProfiles",
    function () return Addon:GetProfiles() end,
    L["API_GETPROFILE_TITLE"],
    L["API_GETPROFILE_DOCS"])

Addon:MakePublic(
    "SetProfile",
    function (profileNameOrId) return Addon:SetProfile(profileNameOrId) end,
    L["API_SETPROFILE_TITLE"],
    L["API_SETPROFILE_DOCS"])

Addon:MakePublic(
    "DestroyItems",
    function ()
        Addon:WithFeature("Destroy", function(destroy)
            destroy:DestroyItems()
        end)
    end,
    L["API_SETPROFILE_TITLE"],
    L["API_SETPROFILE_DOCS"])

