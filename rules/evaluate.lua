-- Rules for determining if an item should be sold.
-- TODO: Make this a dynamic system with default rules and allow user-supplied rules.
function Vendor:EvaluateItemForSelling(item)

	-- Nil is expected for empty bag slots
	if not item then return false end

	-- Blacklist first. We will never sell something on this list, regardless of whatever other criteria it meets.
	if self:IsItemIdInNeverSellList(item.Id) then
		return false
	end

	-- Whitelist comes after blacklist. User said to always sell it, so we will always sell it.
	if self:IsItemIdInAlwaysSellList(item.Id) then
		return true
	end
	
	-- Items with zero value cannot be sold.
	if item.UnitValue == 0 then
		return false
	end

    -- Sell gray garbage.
    if item.Quality == 0 then
        return true
    end
    
    -- Sell Legion AP Items if you are max level in Legion.
    if self.db.profile.sellartifactpower and item.IsArtifactPower and item.ExpansionPackId == 6 and tonumber(UnitLevel("player")) >= 110 then
        return true
    end
    
	-- We don't sell anything epic or higher or white items, which usually have special meaning or crafting materials.
	if item.Quality > 3 or item.Quality == 1 then 
		return false
	end
	

	
	-- Don't sell uncollected transmogs.
	if item.IsUnknownAppearance then
		return false
	end
	
	
	-- From here on out we don't sell soulbound.
	-- TODO: This should be an option, but it is dangerous to allow it.
	if item.IsSoulbound then
		return false
	end
	
	-- Auto sell green gear per settings.
	if self.db.profile.sellgreens and item.Quality == 2 and (item.TypeId == 2 or item.TypeId == 4) and item.Level < self.db.profile.sellgreensilvl then
		return true
	end
	
	-- Auto sell blue gear per settings.
	if self.db.profile.sellblues and item.Quality == 3 and (item.TypeId == 2 or item.TypeId == 4) and item.Level < self.db.profile.sellbluesilvl then
		return true
	end

	-- Doesn't fit one of our above sell criteria so we keep it.
	return false
end


