--[[===========================================================================
	| Copyright (c) 2018
	|
    | ItemList:
    ========================================================================--]]

	local Addon, L, Config = _G[select(1,...).."_GET"]()
	local ItemList = {}
	local Package = select(2, ...);
	
	function ItemList:CreateItem(itemId)
		print("-----> item", itemId);
		local item = Mixin(CreateFrame("Button", nil, self, "Vendor_Item_Template"), Package.ItemListItem);
		self.itemHeight = item:GetHeight();
		return item;
	end

	function ItemList:createModel(listType)
		local list = Addon:GetBlocklist(listType);
		local model = {};

		for id, v in pairs(list) do
			if (v) then
				table.insert(model, id);
			end
		end

		print("table:", model, table.getn(model));
		return model;
	end
		
	function ItemList:OnUpdateItem(item, isFirst, isLast)
	end
	
	function ItemList:OnViewBuilt()
	end
		
	function ItemList.OnLoad(self)
		Mixin(self, ItemList, Package.ListBase);
		self:AdjustScrollbar();
	end
	
	function ItemList:OnShow()
		print("---- list always show");
		self:UpdateView(self:createModel(Addon.c_AlwaysSellList));
	end
	
	function ItemList:RefreshView()
	end	

	Package.ItemList = ItemList;
	Addon.ItemList = ItemList;