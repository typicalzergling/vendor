-- Addon core. Handles initialization and first-run setup. 
local _, Addon = ...
local L = Addon:GetLocale()

-- Strings for the binding XML. This must be loaded after all the locales have been initialized.
--[[
    Commenting all this out because Blizzard broke keybindings. Any attempt to localize them
    with a variable results in taint. Rip.
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
]]
-- This is the first event fired after Addon is completely ready to be loaded.
-- This is one-time initialization and setup.
function Addon:OnInitialize()
    self:GenerateEvents(self.Events)

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
    -- TODO: Move each of these to their own file's initialize call for modularity.
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
    self:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", "AutoConfirmSellTradeRemoval")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "OnBagUpdate")

    -- Merchant Button
    --self.MerchantButton.Initialize()

    Addon:InitializeItemResultRefresh()
    Addon:InitializeEvaluationStatus()
    Addon:InitializeItemTooltips()
    Addon:InitializeLDBPlugin()
    
    -- Do a delayed pruning of history across all characters.
    Addon:PostInitializePruneHistory()
end
