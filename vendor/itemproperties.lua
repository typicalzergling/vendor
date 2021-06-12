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
    item.IsBindOnEquip = false
    item.IsBindOnUse = false
    item.IsUnknownAppearance = false
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
    item.Type = getItemInfo[6]              -- Note: This is localized, TypeId better to use for rules.
    item.MinLevel = getItemInfo[5]
    item.TypeId = getItemInfo[12]
    item.SubType = getItemInfo[7]           -- Note: This is localized, SubTypeId better to use for rules.
    item.SubTypeId = getItemInfo[13]
    item.BindType = getItemInfo[14]
    item.StackSize = getItemInfo[8]
    item.UnitValue = getItemInfo[11]
    item.IsCraftingReagent = getItemInfo[17]
    item.IsUnsellable = not item.UnitValue or item.UnitValue == 0
    item.ExpansionPackId = getItemInfo[15]  -- May be useful for a rule to vendor previous ex-pac items, but doesn't seem consistently populated
    item.IsAzeriteItem = (getItemInfo[15] == 7) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.Link);

    -- Check for usability
    item.IsUsable = IsUsableItem(item.Id)

    -- Save string compares later.
    item.IsEquipment = item.EquipLoc ~= "" and item.EquipLoc ~= "INVTYPE_BAG"
    item.IsEquipped = item.Location:IsEquipmentSlot()

    -- Get soulbound information
    if C_Item.IsBound(location) then
        item.IsSoulbound = true         -- This actually also covers account bound.
    else
        if item.BindType == 2 then
            item.IsBindOnEquip = true
        elseif item.BindType == 3 then
            item.IsBindOnUse = true
        end
    end

    -- Determine if this item is an uncollected transmog appearance
    -- We can save the scan by skipping if it is Soulbound (would already have it) or not equippable
    if not item.IsSoulbound and item.IsEquipment then
        if self:IsItemUnknownAppearanceInTooltip(item.Location) then
            item.IsUnknownAppearance = true
        end
    end

    --[[
    -- Determine if crafting reagent
    -- These are typically itemtype 7, which is 'tradeskill' but sometimes item type 15, which is miscellaneous.
    if item.TypeId == 7 or item.TypeId == 15 then
        if self:IsItemCraftingReagentInTooltip(item.Location) then
            item.IsCraftingReagent = true
        end
    end
    ]]

    -- Pet collection items appear to be type 15, subtype 2 (Miscellaneous - Companion Pets)

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

