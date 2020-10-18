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
	
function ItemList:CreateItem(itemId)
	local item = Mixin(CreateFrame("Button", nil, self, "Vendor_Item_Template"), Package.ItemListItem);
	item:SetItem(itemId);
	return item;
end

function ItemList:createModel()
	local list = Addon:GetList(self.listType);
	local model = {};

	for id, v in pairs(list:GetContents()) do
		if (v) then
			table.insert(model, id);
		end
	end

	return model;
end
	
function ItemList:OnUpdateItem(item, isFirst, isLast)
end

function ItemList:OnViewBuilt()
end
	
function ItemList.OnLoad(self)
	Mixin(self, ItemList, Package.ListBase);
	self:AdjustScrollbar();
	Addon.Profile:RegisterForChanges(
		function()
			if (self:IsShown()) then
				self:UpdateView(self:createModel());
			end
		end
	);

	if (self.emptyText) then
		if (self.listType == SELL_LIST) then
			self.emptyText:SetText(L["ITEMLIST_EMPTY_SELL_LIST"]);
		elseif (self.listType == KEEP_LIST) then
			self.emptyText:SetText(L["ITEMLIST_EMPTY_KEEP_LIST"]);
		else
			self.emptyText:SetText("");
		end
	end
end

function ItemList:OnShow()
	self:UpdateView(self:createModel());
end

function ItemList:RefreshView()
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