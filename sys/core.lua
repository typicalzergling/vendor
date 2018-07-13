-- Vendor core. Handles enable/disable of the addon and setting up configuration. Generally loaded 2nd to last, just before config.
local L = Vendor:GetLocalizedStrings()

-- Initialize
function Vendor:OnInitialize()

end

function Vendor:OnEnable()
    -- Set up events
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")

    -- Tooltip hooks
    self:HookScript(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    self:HookScript(ItemRefTooltip, "OnTooltipSetItem", "OnTooltipSetItem")

    self:Debug("Enabled")
end

function Vendor:OnDisable()
    -- ACE handles deregistration of events
    self:UnhookAll()
    self:Debug("Disabled")
end


