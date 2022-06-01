local AddonName, Addon = ...
local L = Addon:GetLocale()


-- We are tracking the location to which the tooltip is currently set. This is because blizzard does not expose
-- a way to get the item location of the tooltip item. So we track the state and the location by hooking SetBagItem
-- and SetInventoryItem to squirrel away that data and clear it whenever the tooltip is hidden. This allows us to
-- know whether a tooltip is referring to an item in the player's bags and then get that item information.
local tooltipLocation = nil

function Addon:GetTooltipItemLocation()
    return tooltipLocation
end

local function clearTooltipState()
    tooltipLocation = nil
end

-- Hook for tooltip SetBagItem
-- Since this is an insecure hook, we will wrap our actual work in a pcall so we can't create taint to blizzard.
-- TODO: Move this into skeleton, since this should be what you do for every insecure hook
function Addon:OnGameTooltipSetBagItem(tooltip, bag, slot)
    local status, err = xpcall(
        function(b, s)
            tooltipLocation = ItemLocation:CreateFromBagAndSlot(b, s)
        end,
        CallErrorHandler, bag, slot)
    if not status then
        Addon:Debug("itemerrors", "Error executing OnGameTooltipSetBagItem: ", tostring(err))
    end
end

-- Hook for SetInventoryItem
-- Since this is an insecure hook, we will wrap our actual work in a pcall so we can't create taint to blizzard.
function Addon:OnGameTooltipSetInventoryItem(tooltip, unit, slot)
    local status, err = xpcall(
        function(u, s)
            if u == "player" then
                tooltipLocation = ItemLocation:CreateFromEquipmentSlot(s)
            else
                clearTooltipState()
            end
        end,
        CallErrorHandler, unit, slot)
    if not status then
        Addon:Debug("itemerrors", "Error executing OnGameTooltipSetInventoryItem: ", tostring(err))
    end
end

-- Hook for Hide
-- This is a secure hook.
function Addon:OnGameTooltipHide(tooltip)
    clearTooltipState()
end


local function GetAppearanceInfo(appearanceId)
    local appearanceCollected = false
        --categoryID, visualID, canEnchant, icon, isCollected, itemLink, transmogLink, unknown1, itemSubTypeIndex = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)


        isCollected = select(5, C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID))


    local playerCanCollect = false
    local accountCanCollect = false
    local sources = C_TransmogCollection.GetAppearanceSources(appearanceId)
    if sources then
        print("Have sources..")
        for i, source in pairs(sources) do
            -- If the player can collect it, then so can the account.
            local hasData, canCollect = C_TransmogCollection.PlayerCanCollectSource(source.sourceID)
            if canCollect then
                playerCanCollect = true
                --accountCanCollect = true
                --break
            end
            -- If player cannot collect, see if account can.
            hasData, canCollect =_TransmogCollection.AccountCanCollectSource(source.sourceID)
            if canCollect then
                accountCanCollect = true
                -- Can't break here because other sources may be player collectable.
            end
        end
    end
    return playerCanCollect, accountCanCollect
end

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

function Addon:GetItemProperties(arg1, arg2)

    local tooltip = nil
    local location = nil

    -- Location directly passed in
    if type(arg1) == "table" then
        location = arg1

    -- Bag and Slot passed in
    elseif type(arg1) == "number" and type(arg2) == "number" then
        location = ItemLocation:CreateFromBagAndSlot(arg1, arg2)
    else
        assert("Invalid arguments to GetItemProperties")
        return nil
    end

    -- No loc means no item.
    if not location or not C_Item.DoesItemExist(location) then
        return nil
    end

    -- Get link from location
    local link = C_Item.GetItemLink(location)

    -- Guid is how we uniquely identify items.
    local guid = C_Item.GetItemGUID(location)

    -- If it's bag and slot then the count can be retrieved, if it isn't
    -- then it must be an inventory slot, which means 1.
    local count = 1
    if location:IsBagAndSlot() then
        count = select(2, GetContainerItemInfo(location:GetBagAndSlot()))
    end

    -- Item properties may already be cached
    local item = Addon:GetItemFromCache(guid)
    if item then
        -- Return cached item and count
        return item, count
    else
        -- Item not cached, so we need to populate the properties.
        item = {}
        -- Item may not be loaded, need to handle this in a non-hacky way.
        item.GUID = guid
        item.Location = location
        item.Link = link
    end

    -- Get more id and cache GetItemInfo, because we aren't bad.
    local getItemInfo = {GetItemInfo(item.Link)}

    -- Safeguard to make sure GetItemInfo returned something. If not bail.
    -- This will happen if we get this far with a Keystone, because Keystones aren't items. Go figure.
    if #getItemInfo == 0 then return nil end

    -- Initialize properties to boolean false for easier rule ingestion.
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
    item.Id = self:GetItemIdFromString(item.Link)
    item.Name = getItemInfo[1]
    item.Quality = getItemInfo[3]
    item.EquipLoc = getItemInfo[9]          -- This is a non-localized string identifier. Wrap in _G[""] to localize.
    item.EquipLocName = _G[item.EquipLoc]
    item.EquipLocName = item.EquipLocName or "" -- Make sure its populated
    item.Type = getItemInfo[6]              -- Note: This is localized, TypeId better to use for rules.
    item.MinLevel = getItemInfo[5]
    item.TypeId = getItemInfo[12]
    item.SubType = getItemInfo[7]           -- Note: This is localized, SubTypeId better to use for rules.
    item.SubTypeId = getItemInfo[13]
    item.BindType = getItemInfo[14]
    item.StackSize = getItemInfo[8]
    item.StackCount = C_Item.GetStackCount(item.Location)
    item.UnitValue = getItemInfo[11]
    item.IsCraftingReagent = getItemInfo[17]
    item.IsUnsellable = not item.UnitValue or item.UnitValue == 0
    item.ExpansionPackId = getItemInfo[15]  -- May be useful for a rule to vendor previous ex-pac items, but doesn't seem consistently populated
    item.IsAzeriteItem = (getItemInfo[15] == 7) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.Link);
    item.InventoryType = C_Item.GetItemInventoryType(item.Location)

    -- Add Bag and Slot information. Initialize to -1 so rule writers can identify them.
    item.Bag = -1
    item.Slot = -1
    item.IsBagAndSlot = item.Location:IsBagAndSlot()
    if item.IsBagAndSlot then
        item.Bag, item.Slot = item.Location:GetBagAndSlot()
    end

    item.IsUsable = IsUsableItem(item.Id)
    item.IsEquipment = IsEquippableItem(item.Id)
    item.IsEquipped = item.Location:IsEquipmentSlot()
    item.IsTransmogEquipment = isTransmogEquipment(item.EquipLoc)

    -- Get soulbound information
    if C_Item.IsBound(location) then
        item.IsSoulbound = true         -- This actually also covers account bound.
        -- TODO watch for better way. Blizzard API doesn't expose it, which means we need
        -- to scan the tooltip, which sucks.
        if self:IsItemAccountBoundInTooltip(item.Location) then
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
    if item.IsEquipment and self:IsItemCosmeticInTooltip(item.Location) then
        item.IsCosmetic = true
    end

    -- Get Transmog info
    -- We aren't using PlayerHasTransmog becuase item id is unreliable, better to use the actual itemloc & appearance info.
    item.IsCollected = false
    -- We do not expose appearanceId of an item, becuase it will be 0 if the player cannot use it.
    -- This could lead to trying to collect an appearance and getting false positives.
    local appearanceId = 0
    local baseItemTransmogInfo = C_Item.GetBaseItemTransmogInfo(item.Location);
    local baseInfo = C_TransmogCollection.GetAppearanceInfoBySource(baseItemTransmogInfo.appearanceID);
    if baseInfo then
        -- This will be zero if the player cannot use the item. More blizzard being awesome.
        appearanceId = baseInfo.appearanceID
        item.IsCollected = baseInfo.appearanceIsCollected
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

    -- Determine if this is a toy.
    -- Toys are typically type 15 (Miscellaneous), but sometimes 0 (Consumable), and the subtype is very inconsistent.
    -- Since blizz is inconsistent in identifying these, we will just look at these two types and then check the tooltip.
    if item.TypeId == 15 or item.TypeId == 0 then
        if self:IsItemToyInTooltip(item.Location) then
            item.IsToy = true
        end
    end

    -- Determine if this is an already-collected item, which should only be usable items.
    if item.IsUsable then
        if self:IsItemAlreadyKnownInTooltip(item.Location) then
            item.IsAlreadyKnown = true
        end
    end

    -- Import the tooltip text as item properties for custom rules.
    item.TooltipLeft = self:ImportTooltipTextLeft(item.Location)
    item.TooltipRight = self:ImportTooltipTextRight(item.Location)

    Addon:AddItemToCache(item, guid)
    return item, count
end

-- Both bag and slot must be numbers and both passed in.
function Addon:GetItemPropertiesFromBag(bag, slot)
    return self:GetItemProperties(bag, slot)
end

-- If we have a tooltip we will use it for scanning.
-- Tooltip is optional
function Addon:GetItemPropertiesFromTooltip()
    return self:GetItemProperties(tooltipLocation)
end

-- Pure location item
function Addon:GetItemPropertiesFromLocation(location)
    return self:GetItemProperties(location)
end

