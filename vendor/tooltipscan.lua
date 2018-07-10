-- Tooltip scanning for item information. This is necessary because not all information is available via item info API.

-- Create tooltip used for scanning items for properties not available normally.
-- Following wowwiki's example here.
local loaded = false
local scanningtip = CreateFrame('GameTooltip', 'VendorScanningTip', nil, 'GameTooltipTemplate')
scanningtip:SetOwner(WorldFrame, 'ANCHOR_NONE')

-- Text scan for left text.
function Vendor:IsStringInTooltipLeftText(tooltip, bag, slot, str)
    -- We assume the tooltip is the GameTooltip
    local tooltipTextLeft = "GameTooltipTextLeft"

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipTextLeft = "VendorScanningTipTextLeft"
        if bag and slot then
            tooltip:SetBagItem(bag, slot)
        else
            self:Debug("Invalid arguments to Tooltip Scanner")
            return false
        end
    end

    -- Scan the tooltip left text.
    for i=1, tooltip:NumLines() do
        local left = _G[tooltipTextLeft..i]
        local text = left:GetText()
        if text and string.find(text, str) then
            return true
        end
    end
    return false
end

-- Soulbound
function Vendor:IsItemSoulboundInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, _G["ITEM_SOULBOUND"])
end

-- You haven't collected this appearance
function Vendor:IsItemUnknownAppearanceInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, _G["TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN"])
end

-- Artifact Power
function Vendor:IsItemArtifactPowerInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, _G["ARTIFACT_POWER"])
end
