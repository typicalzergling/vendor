local L = LibStub("AceLocale-3.0"):GetLocale("Vendor")
Vendor = Vendor or {}

-- Gets information about an item 
-- Here is the list of captured item properties.
--     Name
--     Link
--     Id
--     Count
--     Quality		0=Poor, 1=Common, 2=Uncommon, 3=Rare, 4=Epic, 5=Legendary, 6=Artifact, 7=Heirloom
--     Level
--     Type
--     TypeId
--     SubType
--     SubTypeId
--     EquipLoc
--     BindType
--     StackSize
--     UnitValue
--     NetValue
--     ExpansionPackId   6=Legion, everything else appears to be 0, including some legion things (Dalaran Hearthstone)

-- Boolean Properties that may be nil if false (more efficient). 
--     IsEquippable
--     IsSoulbound
--     IsBindOnEquip
--     IsBindOnUse
--     IsArtifactPower
--     IsUnknownAppearance

-- Gets information about the item in the specified slot.
-- If we pass in a link, use the link. If link is nil, use bag and slot.
-- We do this so we can evaluate based purely on a link, or on item container if we have it.
function Vendor:GetItemProperties(link, bag, slot)
	local item = {}
	
	-- Use bag and slot if we have it so we get an accurate item count and exact link on the item.
	if bag and slot then
		_, item.Count, _, _, _, _, item.Link = GetContainerItemInfo(bag, slot)
	else 
		item.Link = link
		item.Count = 1
	end

	-- No name or quantity means there is no item in that slot. Nil denotes no item.
	if not item.Link then return nil end

	-- Get more id and cache GetItemInfo, because we aren't bad.
	local getItemInfo = {GetItemInfo(item.Link)}
	
	-- Safeguard to make sure GetItemInfo returned something. If not bail.
	-- This will happen if we get this far with a Keystone, because Keystones aren't items. Go figure.
	if #getItemInfo == 0 then return nil end
	
	-- Initialize properties to boolean false for easier rule ingestion.
	item.IsEquippable = false
	item.IsSoulbound = false
	item.IsBindOnEquip = false
	item.IsBindOnUse = false
	item.IsArtifactPower = false
	item.IsUnknownAppearance = false
	
	-- Get the effective item level.
	item.Level = GetDetailedItemLevelInfo(item.Link)
	
	-- Rip out properties from GetItemInfo
	item.Id = self:GetItemId(item.Link)
	item.Name = getItemInfo[1]
	item.Quality = getItemInfo[3]
	item.EquipLoc = getItemInfo[9]			-- This is a non-localized string identifier. Wrap in _G[""] to localize.
	item.Type = getItemInfo[6]				-- Note: This is localized, TypeId better to use for rules.
	item.TypeId = getItemInfo[12]
	item.SubType = getItemInfo[7]			-- Note: This is localized, SubTypeId better to use for rules.
	item.SubTypeId = getItemInfo[13]
	item.BindType = getItemInfo[14]
	item.StackSize = getItemInfo[8]
	item.UnitValue = getItemInfo[11]
	item.ExpansionPackId = getItemInfo[15] 	-- May be useful for a rule to vendor previous ex-pac items, but doesn't seem consistently populated
	
	-- Net Value is net value including quantity.
	item.NetValue = (item.UnitValue or 0) * item.Count
	
	-- Save string compares later.
	item.IsEquippable = item.EquipLoc ~= ""
	
	-- For additional bind information we can be smart and only check the tooltip if necessary. This saves us string compares.
	-- 0 = none, 1 = on pickup, 2 = on equip, 3 = on use, 4 = quest
	if item.BindType == 1 or item.BindType == 4 then
		-- BOP or quest, must be soulbound if it is in our inventory
		item.IsSoulbound = true
	elseif item.BindType == 2 then
		-- BOE, may be soulbound
		if self:IsItemSoulboundInTooltip(link, bag, slot) then
			item.IsSoulbound = true
		else
			-- If it is BoE and isn't soulbound, it must still be BOE
			item.IsBindOnEquip = true
		end
	elseif item.BindType == 3 then
		-- Bind on Use, may be soulbound
		if self:IsItemSoulboundInTooltip(link, bag, slot) then
			item.IsSoulbound = true
		else
			item.IsBindOnUse = true
		end
	else
		-- None, leave nil
	end
	
	-- Determine if this is Artifact Power.
	-- AP items are type Consumable - Other, and have Artifact Power in the tooltip. 
	-- Avoid scanning the tooltip if it isn't that type.
	if item.TypeId == 0 and item.SubTypeId == 8 then
		if self:IsItemArtifactPowerInTooltip(link, bag, slot) then
			item.IsArtifactPower = true
		end
	end
	
	-- Determine if this item is an uncollected transmog appearance
	-- We can save the scan by skipping if it is Soulbound (would already have it) or not equippable
	if not item.IsSoulbound and item.IsEquippable then
		if self:IsItemUnknownAppearanceInTooltip(link, bag, slot) then
			item.IsUnknownAppearance = true
		end
	end
	
	return item
end

-- Wrapper methods for getting item properties based on source.
function Vendor:GetItemPropertiesFromBag(bag, slot)
	return self:GetItemProperties(nil, bag, slot)
end

function Vendor:GetItemPropertiesFromLink(link)
	return self:GetItemProperties(link, nil, nil)
end

-- Used for testing.
function Vendor:GetAllBagItemInformation()
	local items = {}
	for bag=0, NUM_BAG_SLOTS do
		for slot=1, GetContainerNumSlots(bag) do			
			local item = self:GetItemPropertiesFromBag(bag, slot)
			if item then
				table.insert(items, item)
			end
		end
	end

	self:Debug("Items count: "..tostring(self:TableSize(items)));
	return items
end

