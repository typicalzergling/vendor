--[[===========================================================================
	| Copyright (c) 2018
	|
    | ItemList:
    ========================================================================--]]

local AddonName, Addon = ...

local ItemList = {
	OnShow = function(self)
		self.List:EnsureUpdate();
	end,

	OnHide = function(self)
		self.List:ClearUpdate();
	end,
}

-- Returns true if the item is read-only
function ItemList:IsReadOnly()
	local readOnly = self.isReadOnly;
	if (readOnly == nil) then
		readOnly = self:GetParent().isReadOnly;
	end

	if (readOnly == nil) then
		return true;
	end
	
	return (readOnly == true);
end

-- Sets the list of items to display, this is either an array of ItemLocations,
-- a list of item links, or numeric list of item ids.
function ItemList:SetContents(itemList)
	self.contents = itemList or {};
	self.List:UpdateView(self.contents);
end
	
function ItemList.OnLoad(self)
	Mixin(self, CallbackRegistryMixin);
	self.List.isReadOnly = (self.isReadOnly or false);
	CallbackRegistryMixin.OnLoad(self);
	self:OnBackdropLoaded();
	self:GenerateCallbackEvents({"OnAddItem", "OnDeleteItem"});

	Addon.ListBase.OnLoad(Mixin(self.List, Addon.ListBase));
	self.List.emptyText.LocKey = self.EmptyTextKey;
	self.List:AdjustScrollbar();

	self.itemTemplate = "Vendor_ListItem_Item";
	if (self:IsReadOnly()) then
		self.itemTemplate = "Vendor_ListItem_Item_ReadOnly";
	end

	self.List.CreateItem = function(list, item) 
		local frame = CreateFrame("Button", nil, list, self.itemTemplate);
		frame:SetItem(item);
		return frame;
	end;

	self.List.RefreshItem = function(list, frame, item)
		frame:SetItem(item);
	end;

	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
end

function ItemList:OnDrop(button)
	local cursorItem = ItemList.GetCursorItem();
	if (not self:IsReadOnly() and (button == "LeftButton") and cursorItem) then
		self:TriggerEvent("OnAddItem", cursorItem);
		ClearCursor();
	end
end

function ItemList.GetCursorItem()
	local what = GetCursorInfo();
	if (not what or (what ~= "item")) then
		return nil;
	end
	
	item = C_Cursor.GetCursorItem();
	if (item) then
		return item;
	end

	local _, itemId, itemLink = GetCursorInfo();
	if (type(itemLink) == "string") then
		return itemLink;
	end

	if (type(itemId) == "number") then
		return itemId;
	end

	return nil;
end

function ItemList.GetItemId(item)
	if (type(item) == "table") then
		return C_Item.GetItemID(item);
	elseif (type(item) == "string") then
		local itemInfo = Item:CreateFromItemLink(item);
		return itemInfo:GetItemID();
	elseif (type(item) == "number") then
		return item;
	end
	return nil;
end

-- Export to Public
Addon.ItemList = ItemList;
Addon.Public.ItemList = ItemList