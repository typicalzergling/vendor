-- Addon core. Handles initialization and first-run setup.
local Addon, L = _G[select(1,...).."_GET"]()

-- Strings for the binding XML. This must be loaded after all the locales have been initialized.
BINDING_CATEGORY_VENDOR = L["ADDON_NAME"]
BINDING_HEADER_VENDORQUICKLIST = L["BINDING_HEADER_VENDORQUICKLIST"]
BINDING_NAME_VENDORALWAYSSELL = L["BINDING_NAME_VENDORALWAYSSELL"]
BINDING_DESC_VENDORALWAYSSELL = L["BINDING_DESC_VENDORALWAYSSELL"]
BINDING_NAME_VENDORNEVERSELL = L["BINDING_NAME_VENDORNEVERSELL"]
BINDING_DESC_VENDORNEVERSELL = L["BINDING_DESC_VENDORNEVERSELL"]
BINDING_NAME_VENDORRUNAUTOSELL = L["BINDING_NAME_VENDORRUNAUTOSELL"]
BINDING_DESC_VENDORRUNAUTOSELL = L["BINDING_DESC_VENDORRUNAUTOSELL"]

-- This is the first event fired after Addon is completely ready to be loaded.
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
    self:RegisterEvent("SCRAPPING_MACHINE_SHOW", "OnScrappingShown");

    -- Tooltip hooks
    self:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookWidget(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")

    -- Print version and load confirmation to console.
    self:Print("%s %sv%s%s is loaded.", L["ADDON_NAME"], GREEN_FONT_COLOR_CODE, self:GetVersion(), FONT_COLOR_CODE_CLOSE)
end
