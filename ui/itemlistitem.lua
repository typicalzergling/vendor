--[[===========================================================================
    | Copyright (c) 2018
    |
    | ItemListItem:
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()

local Package = select(2, ...);
local ItemListItem = {};

function ItemListItem:OnLoad()
	print("---> item list item load");
end

--[[============================================================================
	| ItemListItem:SetItem
	|   Create the frames which represent the rule parameters.
	==========================================================================]]
function ItemListItem:populate()
	local name = self:GetItemName();
	local color = self:GetItemQualityColor();
	if (not color) then
		color = GRAY_FONT_COLOR;
	end

	self.Text:SetText(name);
	self.Text:SetTextColor(color.r, color.g, color.b);
end

--[[============================================================================
	| ItemListItem:SetItem
	|   Create the frames which represent the rule parameters.
	==========================================================================]]	
function ItemListItem:SetItem(item)
	if (type(item) == "number") then
		self:SetItemID(itemId);
	elseif (type(item) == "string") then			
		self:SetItemLink(item);
	else
		self:SetItemLocation(item);
	end

	-- Test for invalid item
	if (self:IsItemEmpty()) then
		self.Text:SetText(L["ITEMLIST_INVALID_ITEM"])
		self.Text:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		return
	end

	-- If the data isn't cached then we want to note that and setup a callback
	if (not self:IsItemDataCached()) then 
		local color = ITEM_QUALITY_COLORS[0];
		self.Text:SetText(L.ITEMLIST_LOADING);
		self.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
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
		self.Hover:Show();

		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4);

		if (not self:IsItemEmpty()) then
			if (self:IsItemDataCached()) then
				if (self:HasItemLocation()) then
					local location = self:GetItemLocation();
					if (location:IsBagAndSlot()) then
						local bag, slot = location:GetBagAndSlot();
						GameTooltip:SetBagItem(bag, slot);
					elseif (locaion:IsEquipmentSlot()) then
						GameTooltip:SetInventoryItem("player", location:GetEquipmentSlot());
					else
						GameTooltip:SetHyperlink(self:GetItemLink());
					end
				else
					GameTooltip:SetHyperlink(self:GetItemLink());
				end
			else
				GameTooltip:SetText(L["ITEMLIST_LOADING_TOOLTIP"]);
			end
		else
			GameTooltip:SetText(L["ITEMLIST_INVALID_ITEM_TOOLTIP"]);
		end

		GameTooltip:Show();
	end
end

--[[============================================================================
	| RuleItem:OnMouseLeave:
	|   Called when the user mouses off the item
	==========================================================================]]
function ItemListItem:OnMouseLeave()
	--self.background:Hide();
	--self.remove:Hide();
	--self:RegisterForClicks();
	if (self.Hover:IsShown()) then
		self.Hover:Hide();
	end

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

	-- Clicking on empty items removes them also, but they do not have links.
	elseif (self:IsItemEmpty()) then
		local itemId = self.itemId;
		if (listType == Addon.c_AlwaysSellList) then
			Addon:GetList(Addon.c_AlwaysSellList):Remove(itemId);
			Addon:Print(L["ITEMLIST_REMOVE_FROM_SELL_FMT"], tostring(itemId));
		elseif (listType == Addon.c_NeverSellList) then
			Addon:GetList(Addon.c_NeverSellList):Remove(itemId);
			Addon:Print(L["ITEMLIST_REMOVE_FROM_KEEP_FMT"], tostring(itemId));
		end
	end
end
	
Package.ItemListItem = Mixin(ItemListItem, ItemMixin);