--[[===========================================================================
	| Copyright (c) 2018
	|
    | ItemList:
    ========================================================================--]]

	local Addon, L, Config = _G[select(1,...).."_GET"]()
	local ItemList = {}
	local Package = select(2, ...);
	
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
		Config:AddOnChanged(
			function()
				if (self:IsShown()) then
					self:UpdateView(self:createModel());
				end
			end
		);
	end
	
	function ItemList:OnShow()
		self:UpdateView(self:createModel());
	end
	
	function ItemList:RefreshView()
	end	

	Package.ItemList = ItemList;
	Addon.ItemList = ItemList;