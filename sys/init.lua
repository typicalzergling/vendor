-- Msut be loaded AFTER all the localization files have been loaded.
Vendor = LibStub("AceAddon-3.0"):NewAddon(Vendor, "Vendor", "AceEvent-3.0", "AceHook-3.0")
local L = Vendor:GetLocalizedStrings()

-- Strings for the binding XML
BINDING_CATEGORY_VENDOR = L["ADDON_NAME"]
BINDING_HEADER_VENDORQUICKLIST = L["BINDING_HEADER_VENDORQUICKLIST"]
BINDING_NAME_VENDORALWAYSSELL = L["BINDING_NAME_VENDORALWAYSSELL"]
BINDING_DESC_VENDORALWAYSSELL = L["BINDING_DESC_VENDORALWAYSSELL"]
BINDING_NAME_VENDORNEVERSELL = L["BINDING_NAME_VENDORNEVERSELL"]
BINDING_DESC_VENDORNEVERSELL = L["BINDING_DESC_VENDORNEVERSELL"]

-- Constants 
Vendor.c_AlwaysSellList = "always"
Vendor.c_NeverSellList = "never"
Vendor.c_RuleType_Sell = "Sell"
Vendor.c_RuleType_Keep = "Keep"