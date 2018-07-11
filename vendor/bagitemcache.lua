-- Item cache used to store results of scans and track item state for efficient retrieval. This is for bags only, not tooltips.

local bagItemCache = {}

-- Clears either a specific bag slot, an entire bag, or the entire cache
function Vendor:ClearBagItemCache(bag, slot)
    bag = tonumber(bag)
    slot = tonumber(slot)
    if not bag and not slot then
        -- Clear entire cache.
        bagItemCache = {}
        --self:Debug("Cleared entire bag item cache.")
    elseif bag and not slot then
        -- Clear the bag only
        bagItemCache[bag] = {}
        --self:Debug("Cleared bag cache: %d", bag)
    elseif bag and slot and bagItemCache[bag] then
        -- This is clearing a specific item in the cache.
        slot = tonumber(slot)
        bagItemCache[bag][slot] = nil
        --self:Debug("Cleared slot cache: %d, %d", bag, slot)
    else
        -- Invalid input or bag provided, but no slot.
        self:Debug("Invalid arguments to ClearBagItemCache. Bag: "..tostring(bag).." Slot: "..tostring(slot))
        return
    end

    -- If we clear the bag cache, also clear the Tooltip Cache
    self:ClearTooltipResultCache()
end

function Vendor:AddItemToBagItemCache(bag, slot, item)
    --@debug@
    assert(tonumber(bag) and tonumber(slot) and bag >= 0 and bag <= NUM_BAG_SLOTS)
    --@end-debug@
    bag = tonumber(bag)
    slot = tonumber(slot)
    if not bagItemCache[bag] then
        bagItemCache[bag] = {}
    end

    -- Add the item to the cache and clear the tooltip cache (this item may have been updated)
    bagItemCache[bag][slot] = item
    self:ClearTooltipResultCache()
end

function Vendor:IsBagItemCached(bag, slot)
    --@debug@
    assert(tonumber(bag) and tonumber(slot) and bag >= 0 and bag <= NUM_BAG_SLOTS)
    --@end-debug@
    bag = tonumber(bag)
    slot = tonumber(slot)
    if not bagItemCache[bag] then
        return false
    else
        return not not bagItemCache[bag][slot]
    end
end

-- This will get the cached item info from a bag slot
function Vendor:GetBagItemFromCache(bag, slot)
    --@debug@
    assert(tonumber(bag) and tonumber(slot) and bag >= 0 and bag <= NUM_BAG_SLOTS)
    --@end-debug@
    bag = tonumber(bag)
    slot = tonumber(slot)
    -- If its not cached we need to cache it.
    if not self:IsBagItemCached(bag, slot) then
        self:CacheBagItem(bag, slot)
    end

    -- It may be an empty table
    if not bagItemCache[bag][slot].Properties then
        return nil
    end

    return bagItemCache[bag][slot]
end

-- Format of a cached item:
-- item.Properties          Item properties
-- item.Sell                Item evaluation for selling.
-- item.RuleId              RuleId used to determine the evaluation.

function Vendor:CacheBagItem(bag, slot)
    --@debug@
    assert(tonumber(bag) and tonumber(slot) and bag >= 0 and bag <= NUM_BAG_SLOTS)
    --@end-debug@
    bag = tonumber(bag)
    slot = tonumber(slot)

    item = {}
    item.Properties = self:GetItemPropertiesFromBag(bag, slot)
    
    -- Check for empty slot
    if not item.Properties then
        -- Important - we will cache empty slots as empty tables as a marker that the slot has been cached.
        self:AddItemToBagItemCache(bag, slot, {})
        return
    end
    
    -- Do evaluation and cache it.
    item.Sell, item.RuleId = self:EvaluateItemForSelling(item.Properties)
    self:AddItemToBagItemCache(bag, slot, item)
end

-- Fired when a bag's inventory changes.
-- Expected to fire multiple times when moving an item in the inventory, once for source and once for destination.
-- We need to clear the cache for the bag whenever this happens.
function Vendor:OnBagUpdate(event, bag)
    self:ClearBagItemCache(tonumber(bag))
end
