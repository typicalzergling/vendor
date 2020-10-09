--[[===========================================================================
    | Copyright (c) 2018
    |
    | ItemListItem:
    ========================================================================--]]

	local Addon, L, Config = _G[select(1,...).."_GET"]()
	local Package = select(2, ...);
	local ItemListItem = {};
		
	--[[============================================================================
		| RuleItem:CreateParameters
		|   Create the frames which represent the rule parameters.
		==========================================================================]]
	function ItemListItem:ShowDivider(show)
		if (show) then
			 self.divider:Show();
		else
			self.divider:Hide();
		end
	end
	
	--[[============================================================================
		| RuleItem:CreateParameters
		|   Create the frames which represent the rule parameters.
		==========================================================================]]	
	function ItemListItem:SetItem(itemId)
	end
	
	--[[============================================================================
		| RuleItem:SetSelected:
		|   Sets the selected  / enabled state of this item and updates all
		|   the UI to reflect that state.
		==========================================================================]]
	function ItemListItem:SetSelected(selected)
		self.selected = selected;
	end
			
	--[[============================================================================
		| RuleItem:OnMouseEnter:
		|   Called when the user mouses over the item if our item text is truncated
		|   then we will show a tooltip for the item.
		==========================================================================]]
	function ItemListItem:OnMouseEnter()
	end
	
	--[[============================================================================
		| RuleItem:OnMouseLeave:
		|   Called when the user mouses off the item
		==========================================================================]]
	function ItemListItem:OnMouseLeave()
	end
	
	Package.ItemListItem = ItemListItem;
	