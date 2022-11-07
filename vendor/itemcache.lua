-- Item cache used to store item properties so they do not need to be continually re-calculated.
-- Note that we cache based on item guid, which means most properties will not change.
-- However, Item Count depends on whether we are looking at an actual bag item or a link.
-- Links alone will always be Count 1. Items in bags may be count > 1 depending on that.
-- We will not cache an item for every permutation of Count, because Count is not expensive,
-- and we only care when directly querying a bag item, in which case we can update the count
-- AFTER retrieving the cached item.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local itemCache = {}
local bagItemMap = {}

function Addon:AddItemGUIDToBagMap(bag, guid)
    if not bagItemMap[bag] then
        bagItemMap[bag] = {}
    end
    table.insert(bagItemMap[bag], guid)
end

function Addon:ClearItemCacheForBag(bag)
    if not bagItemMap[bag] then return end
    assert(type(bagItemMap[bag]) == "table")
    for i, v in ipairs(bagItemMap[bag]) do
        Addon:ClearItemCache(v)
    end
    bagItemMap[bag] = {}
    Addon:Debug("itemcache", "Cached items in bag %s cleared.", tostring(bag))
end

-- Arg is a location or a guid
function Addon:AddItemToCache(item, arg)
    assert(item)
    assert(arg)
    local guid = nil
    if type(arg) == "table" then
        -- Assume this is a location
        guid = C_Item.GetItemGUID(arg)
    elseif type(arg) == "string" then
        -- Assuming this is directly the guid
        guid = arg
    else
        error("Invalid input into AddItemToCache")
    end

    itemCache[guid] = item
    if item.Bag >= 0 then
        Addon:AddItemGUIDToBagMap(item.Bag, guid)
    end
    Addon:Debug("itemcache", "Added %s to cache for bag %s", tostring(guid), tostring(item.Bag))
    -- If we are caching item properties it means the result cache from previous evaluation
    -- of this GUID may be stale. Clear the result cache for this guid as well.
    Addon:ClearResultCache(guid)
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

-- No args clears everything.
-- String arg assumes it is the GUID
-- Otherwise we assume it is a location.
function Addon:ClearItemCache(arg)
    local guid = nil
    if not arg then
        -- Clear it all
        itemCache = {}
        Addon:ClearResultCache()
        Addon:Debug("itemcache", "Item Cache cleared.")
    elseif type(arg) == "string" then
        -- GUID
        guid = arg
    elseif type(arg) == "table" then
        -- Location
        guid = C_Item.GetItemGUID(arg)
    else
        error("Invalid input into ClearItemCache")
    end

    itemCache[guid] = nil
    Addon:ClearResultCache(guid)
    Addon:Debug("itemcache", "Removed %s from Item Cache.", tostring(guid))
end

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

-- Fires when a bag changes. 
function Addon:OnBagUpdate(bagID)
    -- When a bag changes some items inside it have changed, but we don't know which ones.
    -- To err on the side of safety we will clear the cache for all items in that bag.
    Addon:ClearItemCacheForBag(bagID)
end
