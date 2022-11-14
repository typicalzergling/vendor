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
    return Addon:GetItemResultFromItemResultCacheByGUID(bagItemMap[bag][slot])
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
function Addon:IsBagAndSlotRefreshNeeded(bag, slot)
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
function Addon:RefreshBagAndSlot(bag, slot, force)
    -- Check for remove first as it is the easy case.
    local itemObj = Item:CreateFromBagAndSlot(bag, slot)
    local entry = getItemFromBagMap(bag, slot)

    -- If item is empty it can only be Case #3
    if itemObj:IsItemEmpty() then
        if not entry then return nil end
        Addon:RemoveItemResultFromCacheByGUID(entry.Item.GUID)
        return nil
    -- If it isn't the above case, it must be the case where we need to add or update.
    else
        local item = Addon:GetItemPropertiesFromBagAndSlot(bag, slot)
        local result = Addon:EvaluateItem(item, force)
        local newEntry = createCacheEntryFromItemAndResult(item, result)
        Addon:AddItemResultToItemResultCache(newEntry)
        return newEntry
    end
end

-- Wrapper for getting an item result for the given bag and slot.
function Addon:GetItemResultForBagAndSlot(bag, slot, force)
    if force or Addon:IsBagAndSlotRefreshNeeded(bag, slot) then
        return Addon:RefreshBagAndSlot(bag, slot, true)
    else
        return getItemFromBagMap(bag, slot)
    end
end

-- We use the guid to look up the location and then do normal bag and slot lookup.
function Addon:GetItemResultForTooltip(tooltipData)
    if not tooltipData then return nil end
    if not tooltipData.guid then return nil end
    local location = C_Item.GetItemLocation(tooltipData.guid)
    if not location:IsBagAndSlot() then return nil end
    local bag, slot = location:GetBagAndSlot()
    return Addon:GetItemResultForBagAndSlot(bag, slot)
end

-- Wrapper for GUID-based item lookup.
-- This looks up where the item is if it exists at all
-- If it does exist, we check its location and see if it is fresh. If not, nil.
function Addon:GetItemResultForGUID(guid)
    local entry = Addon:GetItemResultFromItemResultCacheByGUID(guid)
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
function Addon:RemoveItemResultFromCacheByGUID(guid)
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

    -- Wheneve we remove a cache entry it means something is likely stale, clear the tooltip so it refreshes.
    Addon:ClearTooltipResultCache()

    -- Signal the update
    Addon:RaiseEvent(ITEMRESULT_REMOVED, guid)
end

-- Arg is a location or a guid
function Addon:AddItemResultToItemResultCache(cacheEntry)
    assert(type(cacheEntry) == "table" and cacheEntry.Item.GUID, "Invalid CacheEntry")

    -- If there is an existing item GUID entry, we need to remove it first.
    if Addon:IsItemInResultCacheByGUID(cacheEntry.Item.GUID) then
        Addon:RemoveItemResultFromCacheByGUID(cacheEntry.Item.GUID)
    end

    itemResultCache[cacheEntry.Item.GUID] = cacheEntry
    addItemGUIDToBagMap(cacheEntry.Item.GUID, cacheEntry.Item.Bag, cacheEntry.Item.Slot)
    debugp("Added %s to cache for bag %s and slot %s", tostring(cacheEntry.Item.Link), tostring(cacheEntry.Item.Bag), tostring(cacheEntry.Item.Slot))

    -- Wheneve we add a cache entry it may have been an update to and existing entry and therefore tooltip is stale.
    Addon:ClearTooltipResultCache()
    Addon:RaiseEvent(ITEMRESULT_ADDED, cacheEntry.Item.GUID)
end

function Addon:IsItemInResultCacheByGUID(guid)
    assert(type(guid) == "string", "Invalid input to IsItemInResultCacheByGUID")
    return not not itemResultCache[guid]
end

-- Input is a guid. It may be stale. This is the quick and dirty lookup where you get
-- the actual item result.
function Addon:GetItemResultFromItemResultCacheByGUID(guid)
    assert(type(guid) == "string", "Invalid input to GetItemResultFromItemResultCacheByGUID")
    return itemResultCache[guid]
end

-- Nuke the entire site from orbit; it's the only way to be sure.
function Addon:ClearItemResultCache()
    -- Clear it all
    itemResultCache = {}
    bagItemMap = {}
    -- Anytime the Result Cache gets cleared, the Tooltip Result Cache also needs clearing.
    Addon:ClearTooltipResultCache()
    debugp("ItemREsultCache cleared.")
    Addon:RaiseEvent(ITEMRESULT_CACHE_CLEARED)
    return
end

-- Not using this yet, but seems like a good way to keep our data integrity up to date.
function Addon:RemoveMissingItemsFromItemResultCache()
    for guid, v in pairs(itemResultCache) do
        if not C_Item.IsItemGUIDInInventory(guid) then
            Addon:RemoveItemResultFromCacheByGUID(guid)
        end
    end
end

-- Goes through our entire cache and clears any item with the corresponding item ID.
-- This is for handling blocklist updates. Rather than clear everything, we only
-- need to clear the cache for an item that changed. However, we don't use this just yet
-- as any change to a list is also a profile change, which triggers a full cache wipe.
-- Maybe we can find targeted ways to to use this in the future.
-- TODO: Try to use this were we can.
function Addon:ClearItemResultCacheByItemId(itemId)
    for guid, entry in pairs(itemResultCache) do
        if entry.Item.Id == itemId then
            Addon:RemoveItemResultFromCacheByGUID(guid)
        end
    end
end

-- Fires when a bag changes. 
function Addon:OnBagUpdate(bagID)
    -- When a bag changes some items inside it have changed, but we don't know which ones.
    -- Refresh will figure out what ones changed and update the ones that changed.
    -- Use a delay so multiple looting events close together don't have us doing extra work.
    -- Bag updates happen a lot, and we want to be non-intrusive to the player experience.
    -- Using delayed refresh means we will not do any work on a looting event or when items
    -- first appear in the inventory unless players specifically mouse over those items before
    -- we refresh them.
    Addon:StartItemResultRefresh(6)
end

function Addon:OnPlayerEquipmentChanged(slotID)
    -- When player equipment changes, we could likely have some rule evaluations changed, so
    -- we should start a refresh with force function flagged so we always rebuild the cache
    -- after such an event.
    Addon:StartItemResultRefresh(6, true)
end
