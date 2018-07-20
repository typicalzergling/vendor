local Addon, L = _G[select(1,...).."_GET"]()

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

--[[
local function GetItemEquipmentSets(itemId)
    local sets = {}
    local itemSets = C_EquipmentSet.GetEquipmentSetIDs();
    for _, setId in pairs(itemSets) do
        local itemIds = C_EquipmentSet.GetItemIDs(setId)
        for _, id in pairs(itemIds) do
            if itemId == id then
                local name = C_EquipmentSet.GetEquipmentSetInfo(setId)
                table.insert(sets, name)
                break
            end
        end
    end
    return sets
end]]


-- Gets information about the item in the specified slot.
-- If we pass in a link, use the link. If link is nil, use bag and slot.
-- We do this so we can evaluate based purely on a link, or on item container if we have it.
-- Argument combinations
--      tooltip, nil - we will get the item link from the tooltip and use the tooltip for scanning
--      tooltip, link - we will use the link and the tooltip for scanning
--      bag, slot       - we will get link from the containerinfo and use the scanning tip for scanning

function Addon:GetItemProperties(arg1, arg2)
    local item = {}
    local tooltip = nil
    local bag = nil
    local slot = nil

    -- Tooltip passed in. Use the link if provided, otherwise get it from the tooltip.
    if type(arg1) == "table" then
        tooltip = arg1
        if type(arg2) == "string" then
            item.Link = arg2
        else
            _, item.Link = tooltip:GetItem()
        end
        item.Count = 1
        
    -- Bag and Slot passed in
    elseif type(arg1) == "number" and type(arg2) == "number" then
        bag = arg1
        slot = arg2
        _, item.Count, _, _, _, _, item.Link = GetContainerItemInfo(bag, slot)

    else
        self:Debug("Invalid arguments to GetItemProperties")
        return nil
    end
    
    -- No name or quantity means there is no item in that slot. Nil denotes no item.
    if not item.Link then return nil end

    -- Get more id and cache GetItemInfo, because we aren't bad.
    local getItemInfo = {GetItemInfo(item.Link)}
    
    -- Safeguard to make sure GetItemInfo returned something. If not bail.
    -- This will happen if we get this far with a Keystone, because Keystones aren't items. Go figure.
    if #getItemInfo == 0 then return nil end
    
    -- Initialize properties to boolean false for easier rule ingestion.
    item.IsEquipment = false
    item.IsSoulbound = false
    item.IsBindOnEquip = false
    item.IsBindOnUse = false
    item.IsArtifactPower = false
    item.IsUnknownAppearance = false
    item.IsToy = false
    item.IsAlreadyKnown = false

    -- Get the effective item level.
    item.Level = GetDetailedItemLevelInfo(item.Link)

    -- Rip out properties from GetItemInfo
    item.Id = self:GetItemId(item.Link)
    item.Name = getItemInfo[1]
    item.Quality = getItemInfo[3]
    item.EquipLoc = getItemInfo[9]          -- This is a non-localized string identifier. Wrap in _G[""] to localize.
    item.Type = getItemInfo[6]              -- Note: This is localized, TypeId better to use for rules.
    item.TypeId = getItemInfo[12]
    item.SubType = getItemInfo[7]           -- Note: This is localized, SubTypeId better to use for rules.
    item.SubTypeId = getItemInfo[13]
    item.BindType = getItemInfo[14]
    item.StackSize = getItemInfo[8]
    item.UnitValue = getItemInfo[11]
    item.ExpansionPackId = getItemInfo[15]  -- May be useful for a rule to vendor previous ex-pac items, but doesn't seem consistently populated

    -- Net Value is net value including quantity.
    item.NetValue = (item.UnitValue or 0) * item.Count

    -- Save string compares later.
    item.IsEquipment = item.EquipLoc ~= ""

    -- For additional bind information we can be smart and only check the tooltip if necessary. This saves us string compares.
    -- 0 = none, 1 = on pickup, 2 = on equip, 3 = on use, 4 = quest
    if item.BindType == 1 or item.BindType == 4 then
        -- BOP or quest, must be soulbound if it is in our inventory
        item.IsSoulbound = true
    elseif item.BindType == 2 then
        -- BOE, may be soulbound
        if self:IsItemSoulboundInTooltip(tooltip, bag, slot) then
            item.IsSoulbound = true
        else
            -- If it is BoE and isn't soulbound, it must still be BOE
            item.IsBindOnEquip = true
        end
    elseif item.BindType == 3 then
        -- Bind on Use, may be soulbound
        if self:IsItemSoulboundInTooltip(tooltip, bag, slot) then
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
        if self:IsItemArtifactPowerInTooltip(tooltip, bag, slot) then
            item.IsArtifactPower = true
        end
    end

    -- Determine if this item is an uncollected transmog appearance
    -- We can save the scan by skipping if it is Soulbound (would already have it) or not equippable
    if not item.IsSoulbound and item.IsEquipment then
        if self:IsItemUnknownAppearanceInTooltip(tooltip, bag, slot) then
            item.IsUnknownAppearance = true
        end
    end

    -- Pet collection items appear to be type 15, subtype 2 (Miscellaneous - Companion Pets)

    -- Determine if this is a toy.
    -- Toys are typically type 15 (Miscellaneous), but sometimes 0 (Consumable), and the subtype is very inconsistent.
    -- Since blizz is inconsistent in identifying these, we will just look at these two types and then check the tooltip.
    if item.TypeId == 15 or item.TypeId == 0 then
        if self:IsItemToyInTooltip(tooltip, bag, slot) then
            item.IsToy = true
        end
    end

    -- Determine if this is an already-collected item
    -- For now limit to toys, but it could be other types, like Recipes
    if item.IsToy then
        if self:IsItemAlreadyKnownInTooltip(tooltip, bag, slot) then
            item.IsAlreadyKnown = true
        end
    end

    return item
end

-- Both bag and slot must be numbers and both passed in.
function Addon:GetItemPropertiesFromBag(bag, slot)
    return self:GetItemProperties(bag, slot)
end

-- Link is optional, will be gotten from the tooltip if not provided.
function Addon:GetItemPropertiesFromTooltip(tooltip, link)
    return self:GetItemProperties(tooltip, link)
end

-- Item Helpers

-- Gets item ID from an itemstring or item link
-- If a number is passed in it assumes that is the ID
function Addon:GetItemId(str)
    -- extract the id
    if type(str) == "number" or tonumber(str) then
        return tonumber(str)
    elseif type(str) == "string" then
        return tonumber(string.match(str, "item:(%d+):"))
    else
        return nil
    end
end

-- Assumes link
function Addon:GetLinkString(link)
    if link and type(link) == "string" then
        local _, _, lstr = link:find('|H(.-)|h')
        return lstr
    else
        return nil
    end
end

-- Returns table of link properties
function Addon:GetLinkProperties(link)
    local lstr = self:GetLinkString(link)
    if lstr then
        return {strsplit(':', lstr)}
    else
        return {}
    end
end
