-- Item cache used to store item properties so they do not need to be continually re-calculated.
-- Note that we cache based on item Link, which means most properties will not change.
-- However, Item Count depends on whether we are looking at an actual bag item or a link.
-- Links alone will always be Count 1. Items in bags may be count > 1 depending on that.
-- We will not cache an item for every permutation of Count, because Count is not expensive,
-- and we only care when directly querying a bag item, in which case we can update the count
-- AFTER retrieving the cached item.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local itemCache = {}

-- Arg is a location or a guid
function Addon:AddItemToCache(item, arg)
    assert(item)
    assert(arg)
    if type(arg) == "table" then
        itemCache[C_Item.GetItemGUID(arg)] = item
    elseif type(arg) == "string" then
        itemCache[arg] = item
    else
        error("Invalid input into AddItemToCache")
    end
end

-- Create this from location. For speed going to assume correctness.
-- location = ItemLocation:CreateFromBagAndSlot(bag, slot)

-- Input is a location or a guid
function Addon:GetItemFromCache(arg)
    assert(arg)
    if type(arg) == "table" then
        return itemCache[C_Item.GetItemGUID(arg)]
    elseif type(arg) == "string" then
        return itemCache[arg]
    else
        error("Invalid input into AddItemToCache")
    end
end

-- Pass in the location or guid, not the item
function Addon:IsItemCached(arg)
    assert(arg)
    if arg == "table" then
        return not not itemCache[C_Item.GetItemGUID(arg)]
    elseif arg == "string" then
        return not not itemCache[arg]
    else
        error("Invalid input into IsItemCached")
    end
end

function Addon:ClearItemCache()
    itemCache = {}
    Addon:Debug("Item Cache cleared.")
    Addon:ClearTooltipResultCache()
end
