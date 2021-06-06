-- Addon core. Handles initialization and first-run setup. 
local _, Addon = ...
local L = Addon:GetLocale()

-- Strings for the binding XML. This must be loaded after all the locales have been initialized.
BINDING_CATEGORY_VENDOR = L["ADDON_NAME"]
BINDING_HEADER_VENDORQUICKLIST = L["BINDING_HEADER_VENDORQUICKLIST"]
BINDING_NAME_VENDORALWAYSSELL = L["BINDING_NAME_VENDORALWAYSSELL"]
BINDING_DESC_VENDORALWAYSSELL = L["BINDING_DESC_VENDORALWAYSSELL"]
BINDING_NAME_VENDORNEVERSELL = L["BINDING_NAME_VENDORNEVERSELL"]
BINDING_DESC_VENDORNEVERSELL = L["BINDING_DESC_VENDORNEVERSELL"]
BINDING_NAME_VENDORRUNAUTOSELL = L["BINDING_NAME_VENDORRUNAUTOSELL"]
BINDING_DESC_VENDORRUNAUTOSELL = L["BINDING_DESC_VENDORRUNAUTOSELL"]
BINDING_NAME_VENDORRULES = L["BINDING_NAME_VENDORRULES"]
BINDING_DESC_VENDORRULES = L["BINDING_DESC_VENDORRULES"]

-- Thanks to Joshua Shearer for identify the fix here!
Addon.IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) or (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

-- This is the first event fired after Addon is completely ready to be loaded.
-- This is one-time initialization and setup.
function Addon:OnInitialize()

    -- Setup Console Commands
    self:SetupConsoleCommands()
    --@debug@
    self:SetupDebugConsoleCommands()
    --@end-debug@

    -- Set up events
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", "AutoConfirmSellTradeRemoval")
	if (not Addon.IsClassic) then
    	self:RegisterEvent("SCRAPPING_MACHINE_SHOW", "OnScrappingShown");
	end

    -- Tooltip hooks
    self:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookWidget(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookFunction(GameTooltip, "SetBagItem", "OnGameTooltipSetBagItem")
    self:PreHookFunction(GameTooltip, "SetInventoryItem", "OnGameTooltipSetInventoryItem")
    self:PreHookWidget(GameTooltip, "OnHide", "OnGameTooltipHide")

    -- Print version and load confirmation to console.
    --self:Print("%s %sv%s%s %s", L["ADDON_NAME"], GREEN_FONT_COLOR_CODE, self:GetVersion(), FONT_COLOR_CODE_CLOSE, L["ADDON_LOADED"])
end

