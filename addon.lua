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
BINDING_NAME_VENDORTOGGLEDESTROY = L["BINDING_NAME_VENDORTOGGLEDESTROY"]
BINDING_DESC_VENDORTOGGLEDESTROY = L["BINDING_DESC_VENDORTOGGLEDESTROY"]
BINDING_NAME_VENDORRUNAUTOSELL = L["BINDING_NAME_VENDORRUNAUTOSELL"]
BINDING_DESC_VENDORRUNAUTOSELL = L["BINDING_DESC_VENDORRUNAUTOSELL"]
BINDING_NAME_VENDORRUNDESTROY = L["BINDING_NAME_VENDORRUNDESTROY"]
BINDING_DESC_VENDORRUNDESTROY = L["BINDING_DESC_VENDORRUNDESTROY"]
BINDING_NAME_VENDORRULES = L["BINDING_NAME_VENDORRULES"]
BINDING_DESC_VENDORRULES = L["BINDING_DESC_VENDORRULES"]

-- This is the first event fired after Addon is completely ready to be loaded.
-- This is one-time initialization and setup.
function Addon:OnInitialize()

    -- Setup Console Commands
    self:SetupConsoleCommands()
    --@debug@
    if self.SetupDebugConsoleCommands then
        self:SetupDebugConsoleCommands()
    end
    --@end-debug@
    --@do-not-package@
    if self.SetupTestConsoleCommands then
        self:SetupTestConsoleCommands()
    end
    --@end-do-not-package@

    -- Set up events
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
    self:RegisterEvent("ITEM_LOCK_CHANGED", "OnItemLockChanged")
    --self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", "AutoConfirmSellTradeRemoval")
    --self:RegisterEvent("USE_NO_REFUND_CONFIRM", function() Addon:Debug("events", "Handling USE_NO_REFUND_CONFIRM") end)
    --self:RegisterEvent("DELETE_ITEM_CONFIRM", function() Addon:Debug("events", "Handling DELETE_ITEM_CONFIRM") end)

    -- Tooltip hooks
    self:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookWidget(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookFunction(GameTooltip, "SetBagItem", "OnGameTooltipSetBagItem")
    self:PreHookFunction(GameTooltip, "SetInventoryItem", "OnGameTooltipSetInventoryItem")
    self:SecureHookWidget(GameTooltip, "OnHide", "OnGameTooltipHide")

    -- Print version and load confirmation to console.
    -- Suppressing for now to reduce spam.
    --self:Print("%s %sv%s%s %s", L["ADDON_NAME"], GREEN_FONT_COLOR_CODE, self:GetVersion(), FONT_COLOR_CODE_CLOSE, L["ADDON_LOADED"])
end

