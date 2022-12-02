-- Item cache used to store item properties so they do not need to be continually re-calculated.
-- Note that we cache based on item guid, which means most properties will not change.
-- However, Item Count depends on whether we are looking at an actual bag item or a link.
-- Links alone will always be Count 1. Items in bags may be count > 1 depending on that.
-- We will not cache an item for every permutation of Count, because Count is not expensive,
-- and we only care when directly querying a bag item, in which case we can update the count
-- AFTER retrieving the cached item.
local AddonName, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("itemcache", ...) end

local Evaluation = Addon.Systems.Evaluation

local itemResultCache = {}
local bagItemMap = {}

-- ItemResult Events
local ITEMRESULT_ADDED = Addon.Events.ITEMRESULT_ADDED
local ITEMRESULT_REMOVED = Addon.Events.ITEMRESULT_REMOVED
local ITEMRESULT_CACHE_CLEARED = Addon.Events.ITEMRESULT_CACHE_CLEARED

local function addItemGUIDToBagMap(guid, bag, slot)
    if not bagItemMap[bag] then
        bagItemMap[bag] = {}
    end
    bagItemMap[bag][slot] = guid
end

local function getItemFromBagMap(bag, slot)
    if not bagItemMap[bag] then return nil end
    if not bagItemMap[bag][slot] then return nil end
    return Evaluation:GetItemResultFromItemResultCacheByGUID(bagItemMap[bag][slot])
end

-- Removes the item at that bag and slot
local function removeItemFromBagMap(bag, slot)
    addItemGUIDToBagMap(nil, bag, slot)
end

-- Assuming item is a table output from GetItemProperties
-- Assuming result from EvaluateItem
-- result.Result
-- result.RuleId
-- result.Rule
-- result.RuleType
local function createCacheEntryFromItemAndResult(item, result)
    assert(type(item) == "table" and item.GUID and item.IsBagAndSlot, "Invalid Item input")
    assert(type(result) == "table" and result.Action, "Invalid Result input")
    local cacheEntry = {}
    cacheEntry.Item = item
    cacheEntry.Result = result
    return cacheEntry
end

-- Assume this is an item in the inventory
-- To save perf, going to make assumptions on input.
local function doesItemMatchCacheEntry(itemObj, entry)
    -- Item matches if it has the same count, same bag and slot, and same GUID
    local location = itemObj:GetItemLocation()
    local guid = C_Item.GetItemGUID(location)
    local count = C_Item.GetStackCount(location)
    -- We assume Bag and Slot are already equal by virtue of how this was called.
    return guid == entry.Item.GUID and count == entry.Item.Count
end

-- Possibilities for Refresh
-- 1) Entry and Item are both empty -> no op
-- 2) Entry and Item are both same item -> no op
-- 3) Item is empty but Entry exists -> Remove entry
-- 4) Item exists but Entry does not -> Add Entry
-- 5) Item exists and Entry exists but are different -> Update Entry (Add)
-- This is expected to be called many times so we will try to keep most
-- calculations here fast and simple.
function Evaluation:IsBagAndSlotRefreshNeeded(bag, slot)
    local itemObj = Item:CreateFromBagAndSlot(bag, slot)
    local entry = getItemFromBagMap(bag, slot)
    if itemObj:IsItemEmpty() then
        if not entry then
            -- Case #1
            return false
        else
            -- Case #3
            return true
        end
    else
        if not entry then
            -- Case #4
            return true
        else
            -- Cases #2 and #5
            return not doesItemMatchCacheEntry(itemObj, entry)
        end
    end
end

-- Refreshes the data on a specific bag and slot.
-- Returns nil if there's no item, or the latest we have on it.
-- The "force" parameter forces a refresh (ignores the cache)
function Evaluation:RefreshBagAndSlot(bag, slot, force)
    -- Check for remove first as it is the easy case.
    local itemObj = Item:CreateFromBagAndSlot(bag, slot)
    local entry = getItemFromBagMap(bag, slot)

    -- If item is empty it can only be Case #3
    if itemObj:IsItemEmpty() then
        if not entry then return nil end
        Evaluation:RemoveItemResultFromCacheByGUID(entry.Item.GUID)
        return nil
    -- If it isn't the above case, it must be the case where we need to add or update.
    else
        local itemProperties = Addon:GetSystem("ItemProperties")
        local item = itemProperties:GetItemPropertiesFromBagAndSlot(bag, slot)
        local result = Evaluation:EvaluateItem(item, force)
        if not item or not result then return nil end
        local newEntry = createCacheEntryFromItemAndResult(item, result)
        Evaluation:AddItemResultToItemResultCache(newEntry)
        return newEntry
    end
end

-- Wrapper for getting an item result for the given bag and slot.
function Evaluation:GetItemResultForBagAndSlot(bag, slot, force)
    if force or Evaluation:IsBagAndSlotRefreshNeeded(bag, slot) then
        return Evaluation:RefreshBagAndSlot(bag, slot, true)
    else
        return getItemFromBagMap(bag, slot)
    end
end

-- We use the guid to look up the location and then do normal bag and slot lookup.
function Evaluation:GetItemResultForTooltip(tooltipData)
    if not tooltipData then return nil end
    if not tooltipData.guid then return nil end
    local location = C_Item.GetItemLocation(tooltipData.guid)
    if not location:IsBagAndSlot() then return nil end
    local bag, slot = location:GetBagAndSlot()
    return Evaluation:GetItemResultForBagAndSlot(bag, slot)
end

-- We use the guid to look up the location and then do normal bag and slot lookup.
function Evaluation:GetItemResultForLocation(location)
    if not location then return nil end
    if not location:IsBagAndSlot() then return nil end
    local bag, slot = location:GetBagAndSlot()
    return Evaluation:GetItemResultForBagAndSlot(bag, slot)
end

-- Wrapper for GUID-based item lookup.
-- This looks up where the item is if it exists at all
-- If it does exist, we check its location and see if it is fresh. If not, nil.
function Evaluation:GetItemResultForGUID(guid)
    -- Putting this as an assert since we can avoid the Classic scenario entirely and its faster.
    assert(not Addon.Systems.Info.IsClassicEra, "Called a method not supported on Classic from Classic")
    local entry = Evaluation:GetItemResultFromItemResultCacheByGUID(guid)
    if not entry then return nil end

    -- We do have an entry, see if the item at that bag and slot matches.
    local itemObj = Item:CreateFromItemGUID(guid)
    if not itemObj or itemObj:IsItemEmpty() then return nil end
    if doesItemMatchCacheEntry(itemObj, entry) then
        return entry
    else
        return nil
    end
end

-- Safe remove guid from cache by also removing it from the bag and slot map.
function Evaluation:RemoveItemResultFromCacheByGUID(guid)
    local item = itemResultCache[guid]
    if not item then return end
    -- Assume that our data integrity isn't hosed and bag map is in sync
    -- this means that the item's current properties for Bag and Slot
    -- Should be where it is in the map.
    local mapEntry = getItemFromBagMap(item.Item.Bag, item.Item.Slot)
    --assert(mapEntry and mapEntry.Item.GUID == guid, "Guid handle leak detected in the cache.")
    if mapEntry and mapEntry.Item.GUID == guid then
        removeItemFromBagMap(item.Item.Bag, item.Item.Slot)
    end
    debugp("Removed %s from cache from bag %s and slot %s", tostring(item.Item.Link), tostring(item.Item.Bag), tostring(item.Item.Slot))
    itemResultCache[guid] = nil

    -- Whenever we remove a cache entry it means something is likely stale, clear the tooltip so it refreshes.
    Addon:ClearTooltipResultCache()

    -- Signal the update
    Addon:RaiseEvent(ITEMRESULT_REMOVED, guid)
end

-- Arg is a location or a guid
function Evaluation:AddItemResultToItemResultCache(cacheEntry)
    assert(type(cacheEntry) == "table" and cacheEntry.Item.GUID, "Invalid CacheEntry")

    -- If there is an existing item GUID entry, we need to remove it first.
    if Evaluation:IsItemInResultCacheByGUID(cacheEntry.Item.GUID) then
        Evaluation:RemoveItemResultFromCacheByGUID(cacheEntry.Item.GUID)
    end

    itemResultCache[cacheEntry.Item.GUID] = cacheEntry
    addItemGUIDToBagMap(cacheEntry.Item.GUID, cacheEntry.Item.Bag, cacheEntry.Item.Slot)
    debugp("Added %s to cache for bag %s and slot %s", tostring(cacheEntry.Item.Link), tostring(cacheEntry.Item.Bag), tostring(cacheEntry.Item.Slot))

    -- Wheneve we add a cache entry it may have been an update to and existing entry and therefore tooltip is stale.
    Addon:ClearTooltipResultCache()
    Addon:RaiseEvent(ITEMRESULT_ADDED, cacheEntry.Item.GUID)
end

function Evaluation:IsItemInResultCacheByGUID(guid)
    assert(type(guid) == "string", "Invalid input to IsItemInResultCacheByGUID")
    return not not itemResultCache[guid]
end

-- Input is a guid. It may be stale. This is the quick and dirty lookup where you get
-- the actual item result.
function Evaluation:GetItemResultFromItemResultCacheByGUID(guid)
    assert(type(guid) == "string", "Invalid input to GetItemResultFromItemResultCacheByGUID")
    return itemResultCache[guid]
end

-- Nuke the entire site from orbit; it's the only way to be sure.
function Evaluation:ClearItemResultCache(reason)
    -- Clear it all
    itemResultCache = {}
    bagItemMap = {}
    -- Anytime the Result Cache gets cleared, the Tooltip Result Cache also needs clearing.
    Addon:ClearTooltipResultCache()
    debugp("ItemResultCache cleared. Reason: %s", tostring(reason) )
    Addon:RaiseEvent(ITEMRESULT_CACHE_CLEARED)
    return
end

-- Not using this yet, but seems like a good way to keep our data integrity up to date.
function Evaluation:RemoveMissingItemsFromItemResultCache()
    for guid, v in pairs(itemResultCache) do
        if not C_Item.IsItemGUIDInInventory(guid) then
            Evaluation:RemoveItemResultFromCacheByGUID(guid)
        end
    end
end

-- Goes through our entire cache and clears any item with the corresponding item ID.
-- This is for handling blocklist updates. Rather than clear everything, we only
-- need to clear the cache for an item that changed. However, we don't use this just yet
-- as any change to a list is also a profile change, which triggers a full cache wipe.
-- Maybe we can find targeted ways to to use this in the future.
-- TODO: Try to use this where we can.
function Evaluation:ClearItemResultCacheByItemId(itemId)
    for guid, entry in pairs(itemResultCache) do
        if entry.Item.Id == itemId then
            Evaluation:RemoveItemResultFromCacheByGUID(guid)
        end
    end
end
