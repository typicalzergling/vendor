--[[===========================================================================
	| Copyright (c) 2018
	|
    | ItemList:
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ItemList = Addon.ItemList or {}
local ItemList = Addon.ItemList

local Package = select(2, ...);
local SELL_LIST = Addon.c_AlwaysSellList;
local KEEP_LIST = Addon.c_NeverSellList;

-- Returns true if the item is read-only
function ItemList:IsReadOnly()
	return (self.isReadOnly == true);
end

-- Sets the list of items to display, this is either an array of ItemLocations,
-- a list of item links, or numeric list of item ids.
function ItemList:SetContents(itemList)
	self.contents = itemList or {};
	self.List:UpdateView(self.contents);
end
	
function ItemList.OnLoad(self)
	Mixin(self, CallbackRegistryMixin);
	self:OnBackdropLoaded();
	self:GenerateCallbackEvents({"OnDropItem", "OnDeleteItem"});

	Mixin(self.List, Package.ListBase);
	self.List.emptyText.LocKey = self.EmptyTextKey;
	self.List:AdjustScrollbar();

	self.List.CreateItem = function(list, item) 
		local frame = CreateFrame("Button", nil, list, self.itemTemplate);
		frame:SetItem(item);
		return frame;
	end;

	self.List.RefreshItem = function(list, frame, item)
		frame:SetItem(item);
	end;

	if (self.emptyText) then
		if (self.listType == SELL_LIST) then
			self.emptyText:SetText(L["ITEMLIST_EMPTY_SELL_LIST"]);
		elseif (self.listType == KEEP_LIST) then
			self.emptyText:SetText(L["ITEMLIST_EMPTY_KEEP_LIST"]);
		else
			self.emptyText:SetText("");
		end
	end

	self.itemTemplate = "Vendor_ListItem_Item";
	if (self:IsReadOnly()) then
		self.itemTemplate = "Vendor_ListItem_Item_ReadOnly";
	end
end

function ItemList:OnDropItem(button)
	if ((button == "LeftButton") and CursorHasItem()) then
		local _, itemId, itemLink = GetCursorInfo();
		if (self.listType == KEEP_LIST) then
			Addon:GetList(KEEP_LIST):Add(itemId);
			Addon:GetList(SELL_LIST):Remove(itemId);
			Addon:Print(L["ITEMLIST_ADD_TO_KEEP_FMT1"], itemLink);
		elseif (self.listType == SELL_LIST) then
			Addon:GetList(KEEP_LIST):Remove(itemId);
			Addon:GetList(SELL_LIST):Add(itemId);
			Addon:Print(L["ITEMLIST_ADD_TO_SELL_FMT1"], itemLink);
		end
		ClearCursor();
	end
end

-- Export to Public
Addon.Public.ItemList = Addon.ItemList