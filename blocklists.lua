-- Manages the always-sell and never-sell blocklists.
Vendor = Vendor or {}

-- Returns 1 if item was added to the list.
-- Returns 2 if item was removed from the list.
-- Returns nil if no action taken.
function Vendor:ToggleItemInBlocklist(list, item)
	
	if not item then return nil end

	local id = self:GetItemId(item)
	if not id then return nil end
	
	-- Add it to the specified list.
	-- If it already existed, remove it from that list.
	if list == self.c_AlwaysSellList then
		if self.db.profile.sell_always[id] then
			self.db.profile.sell_always[id] = nil
			return 2
		else
			-- Add to the list.
			self.db.profile.sell_always[id] = true
			-- Remove from other list.
			self.db.profile.sell_never[id] = nil
			return 1
		end
	elseif list == self.c_NeverSellList then
		if self.db.profile.sell_never[id] then
			self.db.profile.sell_never[id] = nil
			return 2
		else
			-- Add to the list.
			self.db.profile.sell_never[id] = true
			-- Remove from the other list.
			self.db.profile.sell_always[id] = nil
			return 1
		end
	else
		return nil
	end
end

-- Quick direct accessor for Never Sell List
function Vendor:IsItemIdInNeverSellList(id)
	if id then
		return self.db.profile.sell_never[id]
	end
	return false
end

-- Quick direct accessor for Always Sell List
function Vendor:IsItemIdInAlwaysSellList(id)
	if id then
		return self.db.profile.sell_always[id]
	end
	return false
end

-- Returns whether an item is in the list and which one.
function Vendor:GetBlocklistForItem(item)
	local id = self:GetItemId(item)
	if id then
		if self.db.profile.sell_never[id] then
			return self.c_NeverSellList
		elseif self.db.profile.sell_always[id] then
			return self.c_AlwaysSellList
		else
			return nil
		end
	end
	return nil
end

-- Returns the list of items on the black or white list
function Vendor:GetBlocklist(list)
	local vlist = {}
	if list == self.c_AlwaysSellList then
		vlist = self.db.profile.sell_always
	elseif list == self.c_NeverSellList then
		vlist = self.db.profile.sell_never
	end
	return vlist
end

-- Permanently deletes the associated blocklist.
function Vendor:ClearBlocklist(list)
	if list == self.c_AlwaysSellList then
		self.db.profile.sell_always = {}
	elseif list == self.c_NeverSellList then
		self.db.profile.sell_never = {}
	end
end
