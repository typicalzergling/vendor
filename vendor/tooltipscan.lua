-- Tooltip scanning for item information. This is necessary because not all information is available via item info API.

-- Create tooltip used for scanning items for properties not available normally.
-- Following wowwiki's example here.
local loaded = false
local scanningtip = CreateFrame('GameTooltip', 'VendorScanningTip', nil, 'GameTooltipTemplate')
scanningtip:SetOwner(WorldFrame, 'ANCHOR_NONE')

-- Identifies if the item in the specified bag & slot is soulbound. There's no API for this, so have to rip it from the tooltip.
-- We search on the localized global string for the client, so this should work for all locales.
function Vendor:IsItemSoulboundInTooltip(tooltip, bag, slot)
	-- We assume the tooltip is the GameTooltip
	local tooltipTextLeft = "GameTooltipTextLeft"

	-- If we don't have a tooltip, use the scanning tooltip and set the bag item
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

	for i=1, tooltip:NumLines() do
		local left = _G[tooltipTextLeft..i]
		local text = left:GetText()
		if text and string.find(text, _G["ITEM_SOULBOUND"]) then
			return true
		end
	end
	return false
end

-- Identifies if the item is an uncollected appearance.
function Vendor:IsItemUnknownAppearanceInTooltip(link, bag, slot)
	-- We assume the tooltip is the GameTooltip
	local tooltipTextLeft = "GameTooltipTextLeft"

	-- If we don't have a tooltip, use the scanning tooltip and set the bag item
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

	for i=1, scanningtip:NumLines() do
		local left = _G[tooltipTextLeft..i]
		local text = left:GetText()
		if text and string.find(text, _G["TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN"]) then
			return true
		end
	end
	return false
end

-- Identifies if the item is Artifact Power.
function Vendor:IsItemArtifactPowerInTooltip(link, bag, slot)
	-- We assume the tooltip is the GameTooltip
	local tooltipTextLeft = "GameTooltipTextLeft"

	-- If we don't have a tooltip, use the scanning tooltip and set the bag item
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

	for i=1, scanningtip:NumLines() do
		local left = _G[tooltipTextLeft..i]
		local text = left:GetText()
		if text and string.find(text, _G["ARTIFACT_POWER"]) then
			return true
		end
	end
	return false
end
