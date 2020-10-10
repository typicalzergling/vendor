--[[===========================================================================
    | Copyright (c) 2018
    |
    | ItemListItem:
    ========================================================================--]]

	local Addon, L, Config = _G[select(1,...).."_GET"]()
	local Package = select(2, ...);
	local ItemListItem = {};
	local ALWAYS_SELL_LIST = RED_FONT_COLOR_CODE .. "ALWAYS|r";
	local NEVER_SELL_LIOST = GREEN_FONT_COLOR_CODE .. "NEVER|r";
		
	--[[============================================================================
		| RuleItem:CreateParameters
		|   Create the frames which represent the rule parameters.
		==========================================================================]]	
	function ItemListItem:SetItem(itemId)
		local name, link, quality = GetItemInfo(string.format("[item:%d]", itemId));
		local color = ITEM_QUALITY_COLORS[quality]; 
		local text = color.hex .. name .. FONT_COLOR_CODE_CLOSE;
		self.background:SetColorTexture(color.r, color.g, color.b, 0.125);
		self.text:SetText(text);
		self.itemId = itemId;
		self.itemLink = link;
		self.itemColor = color;
		self.remove:Hide();
	end
			
	--[[============================================================================
		| RuleItem:OnMouseEnter:
		|   Called when the user mouses over the item if our item text is truncated
		|   then we will show a tooltip for the item.
		==========================================================================]]
	function ItemListItem:OnMouseEnter()
		self.background:Show();
		self.remove:Show();
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		local listType = self:GetParent().listType;
		
		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4);
		GameTooltip:SetHyperlink(self.itemLink);
		GameTooltip:Show();
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

	function ItemListItem:OnClick(button)
		local listType = self:GetParent().listType;

		if (button == "LeftButton") then
			if (listType == Addon.c_AlwaysSellList) then
				Addon:Print("%s has been removed from the %s sell list", self.itemLink, ALWAYS_SELL_LIST);
				Addon:GetList(Addon.c_AlwaysSellList):Remove(self.itemId);
			elseif (listType == Addon.c_NeverSellList) then
				Addon:Print("%s has been removed from the %s sell list", self.itemLink, NEVER_SELL_LIOST);
				Addon:GetList(Addon.c_NeverSellList):Remove(self.itemId);
			end
		elseif (button == "RightButton") then
			if (listType == Addon.c_AlwaysSellList) then 
				Addon:Print("%s has been moved from the %s sell list to the %s sell list", self.itemLink, NEVER_SELL_LIOST, ALWAYS_SELL_LIST);
				Config:BeginBatch();
					Addon:GetList(Addon.c_AlwaysSellList):Remove(self.itemId);
					Addon:GetList(Addon.c_NeverSellList):Add(self.itemId);
				Config:EndBatch();
			elseif (listType == Addon.c_NeverSellList) then
				Addon:Print("%s has been moved from the %s sell list to the %s sell list", self.itemLink, NEVER_SELL_LIOST, ALWAYS_SELL_LIST);
				Config:BeginBatch();
				Addon:GetList(Addon.c_AlwaysSellList):Add(self.itemId);
				Addon:GetList(Addon.c_NeverSellList):Remove(self.itemId);
			Config:EndBatch();
			end
		end
	end
	
	Package.ItemListItem = ItemListItem;
	