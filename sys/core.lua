-- Addon core. Handles enable/disable of the addon and setting up configuration. 
local Addon, L = _G[select(1,...).."_GET"]()

-- Strings for the binding XML. This must be loaded after all the locales have been initialized.
BINDING_CATEGORY_VENDOR = L["ADDON_NAME"]
BINDING_HEADER_VENDORQUICKLIST = L["BINDING_HEADER_VENDORQUICKLIST"]
BINDING_NAME_VENDORALWAYSSELL = L["BINDING_NAME_VENDORALWAYSSELL"]
BINDING_DESC_VENDORALWAYSSELL = L["BINDING_DESC_VENDORALWAYSSELL"]
BINDING_NAME_VENDORNEVERSELL = L["BINDING_NAME_VENDORNEVERSELL"]
BINDING_DESC_VENDORNEVERSELL = L["BINDING_DESC_VENDORNEVERSELL"]

-- Run initialization code.
function Addon:OnInitialize()
    -- Setup Console Commands
    self:SetupConsoleCommands()
    --@debug@
    self:SetupDebugConsoleCommands()
    --@end-debug@
    
    -- Set up events
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("END_BOUND_TRADEABLE", "OnEndBoundTradeable")

    -- Tooltip hooks
    self:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:PreHookWidget(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    --self:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTestHook")
    
    -- Print version and load confirmation to console.
    local version = GetAddOnMetadata(self.c_AddonName, "version")
    --@do-not-package@
    if version == "@project-version@" then version = "Debug" end
    --@end-do-not-package@
    self:Print("%s %sv%s%s is loaded.", L["ADDON_NAME"], GREEN_FONT_COLOR_CODE, version, FONT_COLOR_CODE_CLOSE)
end

function Addon:OnTestHook()

    self:Print("Test Hook worked!")
end