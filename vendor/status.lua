-- Includes methods and mechanisms for getting overall status of what Vendor is tracking with your items.
-- This is usually exported to LibDataBroker for use in Titan and other plugin models and for the minimap.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("status", ...) end

-- Returns num kept, num sold, and num destroyed for a given item id.
-- Note that if this is called while evaluations are still occurring, it will
-- give you a running count, thus far, of items that have been kept/sold/destroyed
-- for this particular item id. This is the basis for the "keep at least N" type
-- rule behavior.
function Addon:GetResultCountsForItemId(id)
    local resultCount = {}
    resultCount[0] = 0
    resultCount[1] = 0
    resultCount[2] = 0

    for guid, entry in pairs(resultCache) do
        -- Find entries with the specified item ID
        if entry.Id == id then
            resultCount[entry.Result] = resultCount[entry.Result] + 1
        end
    end
    -- Num Kept, Num Sold, Num Destroyed
    return resultCount[0], resultCount[1], resultCount[2]
end


-- Setup the evaluation status cache.
local escache = {}
escache = {}
escache.count = 0
escache.value = 0
escache.tosell = 0
escache.todestroy = 0
escache.sellitems = {}
escache.destroyitems = {}

-- This will trigger evaluation if one is not already active.
-- Because of this, it is recommended to not call this method directly but to instead respond to
-- ITEMCACHE_REFRESH_COMPLETE events to signal calculating hte EvaluationSTatus.
function Addon:GetEvaluationStatus()
    return escache.count, escache.value, escache.tosell, escache.todestroy, escache.sellitems, escache.destroyitems
end

-- This method should run after a refresh since all of the items and evaluations will already be cached.
-- This will make it very fast to create the status.
-- Results of the status will be cached until the next time GenerateEvaluationStatus() is called.
function Addon:GenerateEvaluationStatus(force)
    debugp("Generating Evaluation Status")
    local count = 0
    local value = 0
    local tosell = 0
    local todestroy = 0
    local sellitems = {}
    local destroyitems = {}
    for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            -- If the item has not changed this should be just pulling data from the cache.
            -- If it has changed, it will refresh the item, so calling this outside refresh is OK,
            -- however it does a lot more work and is bad for performance. Let Refresh efficiently
            -- update the cache while this piggybacks on that effort to give timely status updates.
            local entry = Addon:GetItemResultForBagAndSlot(bag, slot, force)
            if entry then
                if entry.Result.Action ~= Addon.ActionType.NONE then
                    count = count + 1
                end

                if entry.Result.Action == Addon.ActionType.SELL then
                    value = value + entry.Item.TotalValue
                    tosell = tosell + 1
                    table.insert(sellitems, entry.Item.Link)
                elseif entry.Result.Action == Addon.ActionType.DESTROY then
                    todestroy = todestroy + 1
                    Addon:Debug("destroy", "Marking item: %s for Destroy", entry.Item.Link)
                    table.insert(destroyitems, entry.Item.Link)
                end
            end
        end
    end

    -- Update the cache with the data.
    escache = {}
    escache.count = count
    escache.value = value
    escache.tosell = tosell
    escache.todestroy = todestroy
    escache.sellitems = sellitems
    escache.destroyitems = destroyitems
    Addon:RaiseEvent(Addon.Events.EVALUATION_STATUS_UPDATED)
end

-- Attach generation of evaluation status to completion of an item refresh.
function Addon:InitializeEvaluationStatus()
    Addon:RegisterCallback(Addon.Events.ITEMRESULT_REFRESH_COMPLETE, Addon, Addon.GenerateEvaluationStatus)
end
