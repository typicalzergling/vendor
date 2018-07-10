local L = Vendor:GetLocalizedStrings()

-- Will take whatever item is being moused-over and add it to the Always-Sell list.
function Vendor:AddTooltipItemToSellList(list)
	-- Get the item from 
	name, link = GameTooltip:GetItem();
	if not link then
		self:Print(string.format(L["TOOLTIP_ADDITEM_ERROR_NOITEM"], list))
		return
	end
	
	-- Add the link to the specified blocklist.
	local retval = self:ToggleItemInBlocklist(list, link)
	if retval == 1 then
		self:Print(string.format(L["CMD_SELLITEM_ADDED"], tostring(link), list))
	elseif retval == 2 then
		self:Print(string.format(L["CMD_SELLITEM_REMOVED"], tostring(link), list))		
	end
end

-- Called by keybinds to direct-add items to the blocklists
function Vendor:AddTooltipItemToAlwaysSellList()
	self:AddTooltipItemToSellList(self.c_AlwaysSellList)
end

function Vendor:AddTooltipItemToNeverSellList()
	self:AddTooltipItemToSellList(self.c_NeverSellList)
end

-- Hooks for item tooltips
function Vendor:OnTooltipSetItem(tooltip, ...)
	local name, link = tooltip:GetItem()
	if name then
		self:AddItemTooltipLines(tooltip, link)
	end
end


-- Item Tooltip Cache, so we don't re-evaluate on every scanned
local itemLink = nil
local blockList = nil
local willBeSold = nil

function Vendor:AddItemTooltipLines(tooltip, link)

	-- Check Cache if we already have data for this item from a previous update.
	-- If it isn't in the cache, we need to evaluate this item/link.
	-- If it is in the cache, then we already have our answer, so don't waste perf re-evaluating.
	if not (itemLink == link) then
		-- Get blocklist ifnormation
		list = self:GetBlocklistForItem(link)
		
		-- Evaluate the item for sell
		local item = self:GetItemPropertiesFromTooltip(tooltip, link)
		willBeSold = self:EvaluateItemForSelling(item)
		
		-- Mark it as the current cached item.
		itemLink = link
		self:Debug("Cached item for tooltip: "..link)
	end
	
	-- Add lines to the tooltip we are scanning after we've scanned it.
	-- Check if the item is in the Always or Never sell lists
	if list then
		-- Add Vendor state to the tooltip.
		if list == self.c_AlwaysSellList then 
			tooltip:AddLine(L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"])
		else
			tooltip:AddLine(L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"])
		end
	end
	
	-- Add a warning that this item will be auto-sold on next vendor trip.
	if willBeSold then
		tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
	end
end

--@do-not-package@

function Vendor:DumpItemPropertiesFromTooltip()
	Vendor:DumpTooltipItemProperties()
end

--@end-do-not-package@
