local AddonName, Addon = ...
local L = Addon:GetLocale()


-- Gets information about an item
-- Here is the list of captured item properties.
--     Name
--     Link
--     Id
--     Count
--     Quality      0=Poor, 1=Common, 2=Uncommon, 3=Rare, 4=Epic, 5=Legendary, 6=Artifact, 7=Heirloom
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
--     IsEquipment
--     IsSoulbound
--     IsBindOnEquip
--     IsBindOnUse
--     IsArtifactPower
--     IsUnknownAppearance
--     IsToy = false
--     IsAlreadyKnown = false
--     IsAzeriteItem = false
--     IsCraftingReagent

-- Gets information about the item in the specified slot.
-- If we pass in a link, use the link. If link is nil, use bag and slot.
-- We do this so we can evaluate based purely on a link, or on item container if we have it.
-- Argument combinations
--      location
--      bag, slot             - we will use the location.

-- Because Blizzard doesn't make this easy.
local transmog_invtypes = {
    INVTYPE_HEAD = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_BODY = true,
    INVTYPE_CHEST = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true,
    INVTYPE_WEAPON = true,
    INVTYPE_SHIELD = true,
    INVTYPE_RANGED = true,
    INVTYPE_CLOAK = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_TABARD = true,
    INVTYPE_ROBE = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_THROWN = true,
    INVTYPE_RANGEDRIGHT = true,
}

local function isTransmogEquipment(invtype)
    if not invtype then return false end
    return transmog_invtypes[invtype] or false
end

function Addon:DoGetItemProperties(itemObj)
    assert(type(itemObj) == "table", "Expected an ItemMixin as the argument")
    assert(type(itemObj.GetItemID) == "function", "Expected an ItemMixin as the argument")

    

    -- If the item is empty it doesn't exist so we've got no properties to make
    if (itemObj:IsItemEmpty()) then
        Addon:Debug("itemerrors", "Empty Item Object")
        return nil
    end

    -- Get base information about the item.
    -- Do a deep copy of location in case this is exposing taint opportunities.
    local location = table.copy(itemObj:GetItemLocation()) or false
    local guid = itemObj:GetItemGUID()

    -- If it's bag and slot then the count can be retrieved, if it isn't
    -- then it must be an inventory slot, which means 1.
    local count = 1
    if location and location:IsBagAndSlot() then
        local bag, slot = location:GetBagAndSlot()
        count = (C_Container.GetContainerItemInfo(bag, slot)).stackCount
    end

    -- Item properties may already be cached, if so use it.
    -- Note that while the item guid will have the same properties,
    -- some properties can and will change, like the location and the stack count.
    local item = nil
    if guid then
        item = Addon:GetItemFromCache(guid)
        if item then
            -- Return cached item and count
            return item, count
        end
    end
    
    -- Item not cached, so we need to populate the properties.
    item = {}

    -- Item may not be loaded, need to handle this in a non-hacky way.
    item.GUID = guid or false
    item.Location = location or false
    item.Link = itemObj:GetItemLink()
    item.Count = count

    -- Get more id and cache GetItemInfo, because we aren't bad.
    local getItemInfo = {GetItemInfo(item.Link)}

    -- Safeguard to make sure GetItemInfo returned something. If not bail.
    -- This will happen if we get this far with a Keystone, because Keystones aren't items. Go figure.
    if #getItemInfo == 0 then return nil end

    -- Item GUID is required for tooltip to be valid.
    if not item.GUID then return nil end

    -- Populate tooltip and surface args.
    -- Deep copy to avoid tainting blizzard's internal data.
    item.TooltipData = table.copy(C_TooltipInfo.GetItemByGUID(item.GUID))
    TooltipUtil.SurfaceArgs(item.TooltipData)
    for _, line in ipairs(item.TooltipData.lines) do
        TooltipUtil.SurfaceArgs(line)
    end

    -- Initialize properties for easier rule ingestion.
    item.IsUsable = false
    item.IsEquipment = false
    item.IsSoulbound = false
    item.IsAccountBound = false
    item.IsBindOnEquip = false
    item.IsBindOnUse = false
    item.IsCosmetic = false
    item.IsToy = false
    item.IsAlreadyKnown = false
    item.IsAzeriteItem = false
    item.IsCraftingReagent = false
    item.IsUnsellable = false

    -- Get the effective item level.
    item.Level = GetDetailedItemLevelInfo(item.Link)

    -- Rip out properties from GetItemInfo
    item.Id = itemObj:GetItemID()
    item.Name = getItemInfo[1]
    item.Quality = getItemInfo[3]
    item.EquipLoc = getItemInfo[9]          -- This is a non-localized string identifier. Wrap in _G[""] to localize.
    item.EquipLocName = _G[item.EquipLoc] or ""
    item.Type = getItemInfo[6]              -- Note: This is localized, TypeId better to use for rules.
    item.MinLevel = getItemInfo[5]
    item.TypeId = getItemInfo[12]
    item.SubType = getItemInfo[7]           -- Note: This is localized, SubTypeId better to use for rules.
    item.SubTypeId = getItemInfo[13]
    item.BindType = getItemInfo[14]
    item.StackSize = getItemInfo[8]
    item.StackCount = 1
    item.UnitValue = getItemInfo[11] or 0
    item.TotalValue = item.UnitValue * item.Count
    item.UnitGoldValue = math.floor(item.UnitValue / 10000)
    item.TotalGoldValue = math.floor(item.TotalValue / 10000)
    item.IsCraftingReagent = getItemInfo[17] or false
    item.IsUnsellable = not item.UnitValue or item.UnitValue == 0
    item.ExpansionPackId = getItemInfo[15]  -- May be useful for a rule to vendor previous ex-pac items, but doesn't seem consistently populated
    item.IsAzeriteItem = (getItemInfo[15] == 7) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.Id);
    item.InventoryType = itemObj:GetInventoryType()
    item.IsConduit = false
    item.IsKeystone = C_Item.IsItemKeystoneByID(item.Id) or false
    --IsItemSpecificToPlayerClass

    if (location) then 
        item.StackCount = C_Item.GetStackCount(location) or 1
        item.IsConduit = C_Item.IsItemConduit(location) or false
    end

    -- Add Bag and Slot information. Initialize to -1 so rule writers can identify them.
    item.Bag = -1
    item.Slot = -1
    item.IsBagAndSlot = location and item.Location:IsBagAndSlot()
    if item.IsBagAndSlot then
        item.Bag, item.Slot = location:GetBagAndSlot()
    end

    item.IsUsable = IsUsableItem(item.Id)
    item.IsEquipment = IsEquippableItem(item.Id)
    item.IsEquipped = location and item.Location:IsEquipmentSlot()
    item.IsTransmogEquipment = isTransmogEquipment(item.EquipLoc)

    -- Get soulbound information
    if location and C_Item.IsBound(location) then
        item.IsSoulbound = true         -- This actually also covers account bound.
        -- TODO watch for better way. Blizzard API doesn't expose it, which means we need
        -- to scan the tooltip.
        if self:IsItemAccountBoundInTooltip(item.TooltipData) then
            item.IsAccountBound = true
        end
    else
        if item.BindType == 2 then
            item.IsBindOnEquip = true
        elseif item.BindType == 3 then
            item.IsBindOnUse = true
        end
    end

    -- Determine if this item is cosmetic.
    -- This information is currently not available via API.
    item.IsCosmetic = false
    if location and item.IsEquipment and self:IsItemCosmeticInTooltip(item.TooltipData) then
        item.IsCosmetic = true
    end

    -- Get Transmog info
    -- We aren't using PlayerHasTransmog becuase item id is unreliable, better to use the actual itemloc & appearance info.
    item.IsCollected = false
    local appearanceId = 0
    if (location) then
        -- We do not expose appearanceId of an item, becuase it will be 0 if the player cannot use it.
        -- This could lead to trying to collect an appearance and getting false positives.
        local baseItemTransmogInfo = C_Item.GetBaseItemTransmogInfo(location);
        local baseInfo = C_TransmogCollection.GetAppearanceInfoBySource(baseItemTransmogInfo.appearanceID);
        if baseInfo then
            -- This will be zero if the player cannot use the item. More blizzard being awesome.
            appearanceId = baseInfo.appearanceID
            item.IsCollected = baseInfo.appearanceIsCollected
        end
    end

    -- Treat AppearanceId of 0 as cannot-use. Appearances the player cannot use have appearanceId 0.
    -- Items that dont' have an appearance also have 0. Without tracking appearances across all characters
    -- we don't have a way of knowing just yet whether the appearance is collectable by another character.
    -- However, we can leverage the fact that appearance will be 0 for unusable equipment to identify unusable equipment.
    -- We will assume that rings, cloaks, and the like are "usable" by everyone, even though on some edge cases they are
    -- not. This is a safe assumption for things like "Keep usable gear" or "vendor unusable gear" so we err on the side
    -- of safety.
    item.IsEquippable = false
    if item.IsEquipment and ((not item.IsTransmogEquipment) or (item.IsTransmogEquipment and appearanceId ~= 0)) then
        item.IsEquippable = true
    end

    -- (we could track all appearances on other characters, but there's addons for that and it would be
    -- better to have a plugin for Mog-it or something like that instead of re-writing that code.)
    -- However, we can assume that if the item is BoA or BoE and the player does not have it, that it
    -- could be collectable, and therefore we will err on the side of caution and flag it as collectable
    -- if the player cannot use it but could potentially trade it to other characters.
    -- This may not include illusions. TODO: Check illusion behavior.
    item.IsCollectable = false
    if not item.IsCollected and item.IsTransmogEquipment and (item.IsBindOnEquip or item.IsAccountBound) and not (appearanceId == 0) then
        item.IsCollectable = true
    end

    -- Alias for IsUncollectedAppearance
    item.IsUncollectedAppearance = item.IsCollectable

    -- Determine if this is a toy.
    -- Toys are typically type 15 (Miscellaneous), but sometimes 0 (Consumable), and the subtype is very inconsistent.
    -- Since blizz is inconsistent in identifying these, we will just look at these two types and then check the tooltip.
    item.IsToy = false
    if location and item.TypeId == 15 or item.TypeId == 0 then
        if self:IsItemToyInTooltip(item.TooltipData) then
            item.IsToy = true
        end
    end

    -- Determine if this is an already-collected item, which should only be usable items.
    item.IsAlreadyKnown = false
    if location and item.IsUsable then
        if self:IsItemAlreadyKnownInTooltip(item.TooltipData) then
            item.IsAlreadyKnown = true
        end
    end

    -- Add item to cache
    Addon:AddItemToCache(item, guid)

    return item, count
end

-- Existing functionality which uses what we had before
function Addon:GetItemProperties(arg1, arg2)
    -- Item GUID passed in
    if type(arg1) == "string" then
        return self:GetItemPropertiesFromGUID(arg1)
    end

    -- Location directly passed in
    if type(arg1) == "table" then
        return self:GetItemPropertiesFromLocation(arg1)
    end

    -- Bag and Slot passed in
    if type(arg1) == "number" and type(arg2) == "number" then
        return self:GetItemPropertiesFromBagAndSlot(arg1, arg2)
    end

    assert("Invalid arguments to GetItemProperties")
    return nil
end

-- From Bag & Slot - Both bag and slot must be numbers and both passed in.
function Addon:GetItemPropertiesFromBagAndSlot(bag, slot)
    if not bag or not slot then return nil end
    return self:DoGetItemProperties(Item:CreateFromBagAndSlot(bag, slot))
end

-- From GUID - This is the best way to get an item.
function Addon:GetItemPropertiesFromGUID(guid)
    if not guid then return nil end
    return self:DoGetItemProperties(Item:CreateFromItemGUID(guid))
end

-- From Tooltip
function Addon:GetItemPropertiesFromTooltip()
    local tooltipData = GameTooltip:GetTooltipData()
    if not tooltipData or not tooltipData.guid then return nil end
    return self:GetItemPropertiesFromGUID(tooltipData.guid)
end

-- From Location
function Addon:GetItemPropertiesFromLocation(location)
    if not location or not location:IsValid() then return nil end
    return self:DoGetItemProperties(Item:CreateFromItemLocation(location))
end

-- From Link - Not a great choice, GUID is best.
function Addon:GetItemPropertiesFromItemLink(itemLink)
    if not itemLink then return nil end
    return self:DoGetItemProperties(Item:CreateFromItemLink(itemLink));
end

-- From Equipment Slot
function Addon:GetItemPropertiesFromEquipmentSlot(equip)
    if not equip then return nil end
    return self:DoGetItemProperties(Item:CreateFromEquipmentSlot(equip))
end

-- From Item object directly
function Addon:GetItemPropertiesFromItem(item)
    if not item then return nil end
    return self:DoGetItemProperties(item)
end