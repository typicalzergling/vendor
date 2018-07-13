-- Vendor core. Handles enable/disable of the addon and setting up configuration. Generally loaded 2nd to last, just before config.
local L = Vendor:GetLocalizedStrings()

-- Initialize
function Vendor:OnInitialize()

end

function Vendor:OnEnable()

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
    self:HookScript(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:HookScript(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
end

function Vendor:OnDisable()
    -- ACE handles deregistration of events
    self:UnhookAll()
end


