--[[===========================================================================
    | Copyright (c) 2018
    |
    | ItemListItem:
    ========================================================================--]]

local Addon, L, Config = _G[select(1,...).."_GET"]()
local Package = select(2, ...);
local ItemListItem = {};

--[[============================================================================
	| ItemListItem:SetItem
	|   Create the frames which represent the rule parameters.
	==========================================================================]]
function ItemListItem:populate()
	local name = self:GetItemName();
	local color = self:GetItemQualityColor();
	if (not color) then
		color = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR];
	end

	local text = color.hex .. name .. FONT_COLOR_CODE_CLOSE;
	self.text:SetText(text);
	self.background:SetColorTexture(color.r, color.g, color.b, 0.125);
end

--[[============================================================================
	| ItemListItem:SetItem
	|   Create the frames which represent the rule parameters.
	==========================================================================]]	
function ItemListItem:SetItem(itemId)
	self.itemId = itemId;
	self.remove:Hide();
	self:SetItemID(itemId);

	if (not self:IsItemDataCached()) then 
		local color = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_POOR];
		self.text:SetText(color.hex .. L["ITEMLIST_LOADING"] .. FONT_COLOR_CODE_CLOSE);
		self.background:SetColorTexture(color.r, color.g, color.b, 0.125);
		self:ContinueOnItemLoad(function() self:populate() end);
	else
		self:populate();
	end
end
		
--[[============================================================================
	| RuleItem:OnMouseEnter:
	|   Called when the user mouses over the item if our item text is truncated
	|   then we will show a tooltip for the item.
	==========================================================================]]
function ItemListItem:OnMouseEnter()
	if (not CursorHasItem()) then
		local cached = self:IsItemDataCached();
		local listType = self:GetParent().listType;
		local itemLink = self:GetItemLink();

		self.background:Show();
		if (cached) then
			self.remove:Show();
		end

		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4);
		if (cached) then
			GameTooltip:SetHyperlink(self:GetItemLink());
		else
			GameTooltip:SetText(L["ITEMLIST_LOADING_TOOLTIP"]);
		end
		GameTooltip:Show();
	end
end

--[[============================================================================
	| RuleItem:OnMouseLeave:
	|   Called when the user mouses off the item
	==========================================================================]]
function ItemListItem:OnMouseLeave()
	self.background:Hide();
	self.remove:Hide();
	self:RegisterForClicks();

	if (GameTooltip:IsOwned(self)) then
		GameTooltip:Hide();
	end
end

--[[============================================================================
	| RuleItem:OnClick:
	|   Called when the item is clicked:
	|	LeftButton -> Remove the item from the current list
	|	RightButton -> Swap the item from one list ot the other.
	|
	| If the cursor current has an item, this is equivlent to dropping it
	| on the parent - we delegate that call.
	==========================================================================]]
function ItemListItem:OnClick(button)
	local listType = self:GetParent().listType;
	if (CursorHasItem()) then
		self:GetParent():OnDropItem(button);
	elseif (self:IsItemDataCached()) then
		local itemLink = self:GetItemLink();
		local itemId = self:GetItemID();

		Config:BeginBatch();
		if (button == "LeftButton") then
			if (listType == Addon.c_AlwaysSellList) then
				Addon:GetList(Addon.c_AlwaysSellList):Remove(itemId);
				Addon:Print(L["ITEMLIST_REMOVE_FROM_SELL_FMT"], itemLink);
			elseif (listType == Addon.c_NeverSellList) then
				Addon:GetList(Addon.c_NeverSellList):Remove(itemId);
				Addon:Print(L["ITEMLIST_REMOVE_FROM_KEEP_FMT"], itemLink);
			end
		elseif (button == "RightButton") then
			if (listType == Addon.c_AlwaysSellList) then 
				Addon:GetList(Addon.c_AlwaysSellList):Remove(itemId);
				Addon:GetList(Addon.c_NeverSellList):Add(itemId);
				Addon:Print(L["ITEMLIST_REMOVE_FROM_SELL_TO_KEEP_FMT"], itemLink);
			elseif (listType == Addon.c_NeverSellList) then
				Addon:GetList(Addon.c_AlwaysSellList):Add(itemId);
				Addon:GetList(Addon.c_NeverSellList):Remove(itemId);
				Addon:Print(L["ITEMLIST_MOVE_FROM_KEEP_TO_SELL_FMT"], itemLink);
			end
		end
		Config:EndBatch();
	end
end
	
Package.ItemListItem = Mixin(ItemListItem, ItemMixin);