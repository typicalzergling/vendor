-- Vendor core. Handles enable/disable of the addon and setting up configuration. Generally loaded 2nd to last, just before config.
local L = LibStub("AceLocale-3.0"):GetLocale("Vendor")
Vendor = Vendor or {}

-- Initialize
function Vendor:OnInitialize()

	-- Load the db
	self.db = LibStub("AceDB-3.0"):New("VendorDB", Vendor.defaults)

	-- Register config options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Vendor", Vendor.config, {"ven", "vendor"})
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Vendor", L["ADDON_NAME"])
	
	-- Create sub table for perf options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Vendor.perfconfig", Vendor.perfconfig)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Vendor.perfconfig", L["OPTIONS_CATEGORY_PERFORMANCE"], "Vendor")
	
	-- Create sub table in options for profile management
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Vendor.profiles", profiles)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Vendor.profiles", L["OPTIONS_CATEGORY_PROFILES"], "Vendor")
	
	-- Free up memory of no-longer used vars
	Vendor.config = nil
	Vendor.defaults = nil
end

function Vendor:OnEnable()
	-- Set up events
	self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
	
	-- Tooltip hooks
	self:HookScript(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
	self:HookScript(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")	
	
	self:Debug(L["ENABLED"])
end

function Vendor:OnDisable()
	-- ACE handles deregistration of events
	self:UnhookAll()
	self:Debug(L["DISABLED"])
end


