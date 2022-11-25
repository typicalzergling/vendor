-- Includes methods and mechanisms for getting overall status of what Vendor is tracking with your items.
-- This is usually exported to LibDataBroker for use in Titan and other plugin models and for the minimap.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("status", ...) end

local Status = {
    NAME = "Status",
    VERSION = 1,
    DEPENDENCIES = {
    },
}

Status.c_GenerateThreadName = "GenerateStatus"
Status.c_GenerateThrottleRate = .02
Status.c_GenerateItemsPerCycle = 25
Status.c_UrgentGenerateThrottleRate = .01
Status.c_UrgentGenerateItemsPerCycle = 50

-- Setup the evaluation status cache.
local escache = {}
escache = {}
escache.count = 0
escache.value = 0
escache.tosell = 0
escache.todestroy = 0
escache.sellitems = {}
escache.destroyitems = {}
escache.nextdestroy = ""

-- This is the main bit of information we produce - status on what Vendor is doing.
-- This method can be spammed all the callers want, because it does not cause any work to happen,
-- we'll just keep giving them the same results until that data actually changes.
-- Because of this, it is recommended to not call this method directly as with polling but to
-- instead respond to EVALUATION_STATUS_UPDATED events that signal this will return new data.
function Addon:GetEvaluationStatus()
    return escache.count, escache.value, escache.tosell, escache.todestroy, escache.sellitems, escache.destroyitems, escache.nextdestroy
end

-- Returns num kept, num sold, and num destroyed for a given item id.
-- Note that if this is called while evaluations are still occurring, it will
-- give you a running count, thus far, of items that have been kept/sold/destroyed
-- for this particular item id. This is the basis for the "keep at least N" type
-- rule behavior.
function Status.GetResultCountsForItemId(id)
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


-- This method should run after a refresh since all of the items and evaluations will already be cached.
-- This will make it very fast to create the status.
-- Results of the status will be cached until the next time GenerateEvaluationStatus() is called.
function Status.GenerateEvaluationStatus()
    -- To remove a slight UI stutter of scannign the entire bags, adding a very fast thread
    -- that will yield frequently to allow the UI to update.
    local thread = function()   -- Coroutine Begin
        debugp("Generating Evaluation Status")
        local processed = 0
        local start = GetTime()
        local count = 0
        local value = 0
        local tosell = 0
        local todestroy = 0
        local sellitems = {}
        local destroyitems = {}
        local nextdestroy = nil
        for bag=0, Addon:GetNumTotalEquippedBagSlots() do
            for slot=1, Addon:GetContainerNumSlots(bag) do
                -- If the item has not changed this should be just pulling data from the cache.
                -- If it has changed, it will refresh the item, so calling this outside refresh is OK,
                -- however it does a lot more work and is bad for performance. Let Refresh efficiently
                -- update the cache while this piggybacks on that effort to give timely status updates.
                local entry = Addon:GetItemResultForBagAndSlot(bag, slot)
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
                        if not nextdestroy then
                            nextdestroy = entry.Item.Link
                        end
                    end
                end

                processed = processed + 1
                if Status:IsUrgentRefresh() then
                    if processed % Status.c_UrgentGenerateItemsPerCycle == 0 then
                        coroutine.yield()
                    end
                else
                    if processed % Status.c_GenerateItemsPerCycle == 0 then
                        coroutine.yield()
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
        escache.nextdestroy = nextdestroy or ""
        debugp("Evaluation Status Updated, elapsed: %ss", tostring(GetTime()-start))
        Addon:RaiseEvent(Addon.Events.EVALUATION_STATUS_UPDATED)
    end

    -- Add thread to the thread list and start it.
    if Status:IsUrgentRefresh() then
        Addon:AddThread(thread, Status.c_GenerateThreadName, Status.c_UrgentGenerateThrottleRate)
    else
        Addon:AddThread(thread, Status.c_GenerateThreadName, Status.c_GenerateThrottleRate)
    end
end

function Status:OnInitialize()

    -- Blizzard Events for tracking combat and when bags/equipment changes
    Addon:RegisterEvent("PLAYER_REGEN_ENABLED", Status.OnPlayerLeavingCombat)
    Addon:RegisterEvent("BAG_UPDATE_DELAYED", Status.OnBagUpdate)
    Addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Status.OnPlayerEquipmentChanged)
    -- Profession equipment not quite supported yet, when we do we should trigger on this.
    -- This will trigger a bag update anywa.
    --Addon:RegisterEvent("PROFESSION_EQUIPMENT_CHANGED", "OnPlayerEquipmentChanged")

    -- Internal events for when item cache is cleared to re-trigger a refresh, and when it is completed.
    Addon:RegisterCallback(Addon.Events.ITEMRESULT_CACHE_CLEARED, Status, Status.OnItemResultCacheCleared)
    Addon:RegisterCallback(Addon.Events.ITEMRESULT_REFRESH_COMPLETE, Status, Status.GenerateEvaluationStatus)
end

function Status:OnTerminate()
end

Addon.Features.Status = Status
