local L = Vendor:GetLocalizedStrings()

-- Will take whatever item is being moused-over and add it to the Always-Sell list.
function Vendor:AddToolTipItemToSellList(list)
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
function Vendor:AddToolTipItemToAlwaysSellList()
	self:AddToolTipItemToSellList(self.c_AlwaysSellList)
end

function Vendor:AddToolTipItemToNeverSellList()
	self:AddToolTipItemToSellList(self.c_NeverSellList)
end

-- Hooks for item tooltips
function Vendor:OnTooltipSetItem(tooltip, ...)
	local name, link = tooltip:GetItem()
	if name then
		self:AddItemTooltipLines(tooltip, link)
	end
end

function Vendor:AddItemTooltipLines(tooltip, link)
	-- Check if the item is in the Always or Never sell lists
	local list = self:GetBlocklistForItem(link)
	if list then
		-- Add Vendor state to the tooltip.
		if list == self.c_AlwaysSellList then 
			tooltip:AddLine(L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"])
		else
			tooltip:AddLine(L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"])
		end
	end
	
	-- Evaluate the item for sell
	local item = self:GetItemPropertiesFromLink(link)
	local willBeSold = self:EvaluateItemForSelling(item)
	
	-- Add a warning that this item will be auto-sold on next vendor trip.
	if willBeSold then
		tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
	end
end