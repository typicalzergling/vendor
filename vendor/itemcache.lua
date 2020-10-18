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

function Addon:GetCachedItem(link)
    assert(link)
    item = itemCache[link]
    if item then
        return item
    else
        return nil
    end
end

function Addon:ClearItemCache()
    itemCache = {}
    Addon:Debug("Item Cache cleared.")
    Addon:ClearTooltipResultCache()
end

function Addon:AddItemToCache(item)
    assert(item and item.Link and type(item) == "table" and type(item.Link) == "string")
    itemCache[item.Link] = item
end

function Addon:IsItemCached(link)
    return not not itemCache[link]
end
