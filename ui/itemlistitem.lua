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
	Mixin(self, ItemMixin);
	self:SetScript("OnClick", self.OnClick);
	self:SetScript("OnEnter", self.OnMouseEnter);
	self:SetScript("OnLeave", self.OnMouseLeave);
end

--[[============================================================================
	| ItemListItem:SetItem
	|   Create the frames which represent the rule parameters.
	==========================================================================]]
function ItemListItem:OnUpdate()
	if (self:IsShown()) then
		if (self:IsMouseOver()) then
			self.Hover:Show();
			if (self.Delete) then
				self.Delete:Show();
			end
		else
			self.Hover:Hide();
			if (self.Delete) then
				self.Delete:Hide();
			end
		end
	end
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
	self.item = item;
	if (type(item) == "number") then
		self:SetItemID(item);
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
		self.Text:SetText(L.ITEMLIST_LOADING);
		self.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		self:ContinueOnItemLoad(function() self:populate() end);
	else
		self:populate();
	end
end

function ItemListItem:OnModelChanged(model)
	self:SetItem(model);
end

--[[============================================================================
	| Called when the "delete" button is clicked
	==========================================================================]]
function ItemListItem:HandleDelete()
	if (self.item) then
		Addon.invoke(self:GetParent():GetParent(), "OnDeleteItem", self.item);
	end
end
		
--[[============================================================================
	| Called when the user mouses over the item if our item text is truncated
	| then we will show a tooltip for the item.
	==========================================================================]]
function ItemListItem:OnMouseEnter()
	if (not Addon.ItemList.GetCursorItem()) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
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
	end
end

--[[============================================================================
	| RuleItem:OnMouseLeave:
	|   Called when the user mouses off the item
	==========================================================================]]
function ItemListItem:OnMouseLeave()
	GameTooltip:Hide();
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
	if (Addon.ItemList.GetCursorItem()) then
		self:GetParent():GetParent():OnDrop(button);
	elseif (not self:IsItemEmpty()) then
		PickupItem(self.item);
	end
end
	
Addon.ItemListItem = ItemListItem;