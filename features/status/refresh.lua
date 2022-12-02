-- Includes methods and mechanisms for determining whether data cached data is or needs updating.
-- Also schedules and provides status on any such updating.
-- Data refresh is intended to be a performance improvement system, so it is expected that data
-- may be stale for some period of time, and in most cases that is OK. This system is for how and
-- when we refresh that data and for determining if a given item needs refreshing.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("refresh", ...) end

local Status = Addon.Features.Status

Status.c_RefreshThreadName = "ItemRefresh"
Status.c_RefreshThrottleRate = .05
Status.c_RefreshItemsPerCycle = 4
Status.c_RefreshDelayAfterUpdate = 10
Status.c_UrgentRefreshThrottleRate = .02
Status.c_UrgentRefreshItemsPerCycle = 20
Status.c_UrgentRefreshDelayAfterUpdate = .5

-- Refresh Events
local ITEMRESULT_REFRESH_TRIGGERED = Addon.Events.ITEMRESULT_REFRESH_TRIGGERED
local ITEMRESULT_REFRESH_START = Addon.Events.ITEMRESULT_REFRESH_START
local ITEMRESULT_REFRESH_STOP = Addon.Events.ITEMRESULT_REFRESH_STOP
local ITEMRESULT_REFRESH_COMPLETE = Addon.Events.ITEMRESULT_REFRESH_COMPLETE

-- Refresh data initialization
local refresh = {}
refresh.delayTimer = nil
refresh.urgentRef = {}
refresh.urgentRefCount = 0
refresh.abortedScanDueToCombat = false
refresh.forceNext = false

local function cancelDelayTimer()
    if refresh.delayTimer then
        refresh.delayTimer:Cancel()
        refresh.delayTimer = nil
    end
end

function Status:IsItemResultRefreshInProgress()
    -- We are refreshing if we have a thread active.
    return not not Addon:GetThread(refresh.threadName)
end

function Status:StopItemResultRefresh()
    if Status:IsItemResultRefreshInProgress() then
        debugp("Stopping the refresh thread.")
        Addon:RemoveThread(refresh.threadName)
        Addon:RaiseEvent(ITEMRESULT_REFRESH_STOP)
    end
end

-- Two concepts with Refreshing
-- 1) Urgency - if its an urgent need to refresh, we are much more aggressive and bypass combat checks
--    Urgency is used for situations where UI needs to be responsive (actively selling) and we expect
--    that it is OK to use more resources to do so. By default we are not urgent.
-- 2) Forced Update - forced update means we pass along a flag to bypass checking the item and to
--    instead force-update it. We do this in situations where we have reason to believe that we need
--    a clean re-evaluation because some rules have changed or some state has changed that can invalidate
--    older evaluations.  Urgency implies forced - if you need the data immediately we assume you also
--    want as correct of data as possible.

-- forceNext is an option where we are guaranteed to force an update
-- on the next refresh, even if non-forced refeshes are also triggered.
local forceNext = false


-- Doing basic ref count on callers who want urgent enabled since it is possible multiple callers
-- may want it simultaneously and one may not need it while others still do.
-- Enabling permanent urgent refresh is possible here simply by enabling it with an identifer
-- and never removing it.

function Status:EnableUrgentRefresh(identifier)
    assert(identifier, "Enable Urgent requires an identifier")
    if refresh.urgentRef[identifier] then return end
    refresh.urgentRef[identifier] = true
    refresh.urgentRefCount = refresh.urgentRefCount + 1
    debugp("Enable Urgent. Refcount = %s", tostring(refresh.urgentRefCount))
end

function Status:DisableUrgentRefresh(identifier)
    assert(identifier, "Disable Urgent requires an identifier")
    if not refresh.urgentRef[identifier] then return end
    refresh.urgentRef[identifier] = nil
    refresh.urgentRefCount = refresh.urgentRefCount - 1
    debugp("Disable Urgent. Refcount = %s", tostring(refresh.urgentRefCount))
end

function Status:IsUrgentRefresh()
    return refresh.urgentRefCount > 0
end

function Status:IsForceNextUpdate()
    return refresh.forceNext
end

-- Force update forces rule evaluation for every item in the inventory.
-- This should only be used when absolutely necessary, such as when gear changes
function Status:SetForceUpdateNextRefresh()
    refresh.forceNext = true
end

local function doStartItemRefresh()
    -- Clear the delay timer
    cancelDelayTimer()

    -- Check for combat, do not interfere unless urgent.
    if UnitAffectingCombat("player") and not Status:IsUrgentRefresh() then
        debugp("Player is in combat, cancelling scan. Will resume after combat.")
        refresh.abortedScanDueToCombat = true
        return
    end

    -- Check if we are already in progress
    if Status:IsItemResultRefreshInProgress() then
        -- If already in progress then stop it so we can restart from beginning.
        Status:StopItemResultRefresh()
    end

    -- begin refresh thread
    local thread = function()   -- Coroutine Begin
        debugp("Refresh Started. Urgent = %s", tostring(Status:IsUrgentRefresh()))
        Addon:RaiseEvent(ITEMRESULT_REFRESH_START)
        local profile = Addon:GetProfile()
        local refreshThrottle = profile:GetValue(Addon.c_Config_RefreshThrottle) or 1
        debugp("Starting bag scan")
        local numProcessed = 0
        local start = GetTime()
        for bag=0, Addon:GetNumTotalEquippedBagSlots() do
            for slot=1, Addon:GetContainerNumSlots(bag) do

                -- If we are in combat, stop the scan.
                if UnitAffectingCombat("player") and not Status:IsUrgentRefresh() then
                    debugp("Player entered combat, aborting refresh.")
                    refresh.abortedScanDueToCombat = true
                    return
                end

                if Status:IsForceNextUpdate() or Addon:IsBagAndSlotRefreshNeeded(bag, slot) then
                    Addon:RefreshBagAndSlot(bag, slot, true)
                end

                -- Yield per throttling setting.
                numProcessed = numProcessed + 1
                if Status:IsUrgentRefresh() then
                    if numProcessed % Status.c_UrgentRefreshItemsPerCycle == 0 then
                        coroutine.yield()
                    end
                else
                    if numProcessed % Status.c_RefreshItemsPerCycle == 0 then
                        coroutine.yield()
                    end
                end
            end
        end

        debugp("Refresh Completed. Urgent = %s, Force = %s, Elapsed: %ss", tostring(Status:IsUrgentRefresh()), tostring(Status:IsForceNextUpdate()), tostring(GetTime()-start))
        -- The refresh is complete, so force is no longer necessary.
        refresh.forceNext = false
        Addon:RaiseEvent(ITEMRESULT_REFRESH_COMPLETE)
    end -- Coroutine End

    -- Add thread to the thread list and start it.
    if Status:IsUrgentRefresh() then
        Addon:AddThread(thread, Status.c_RefreshThreadName, Status.c_UrgentRefreshThrottleRate)
    else
        Addon:AddThread(thread, Status.c_RefreshThreadName, Status.c_RefreshThrottleRate)
    end
end

-- ItemResultRefresh has optional argument for delay in seconds.
function Status:StartItemResultRefresh(delayInSeconds)
    assert(not delayInSeconds or type(delayInSeconds) == "number")

    -- If we are already pending a delay, this call will overwrite that delay.
    -- Note that immediate call with no delay will always be immediate.
    cancelDelayTimer()

    -- Urgency alters the delay from Prius to Porche
    -- We still want a short delay so we dont fire off a ton of urgent refreshes back to back.
    if self:IsUrgentRefresh() then
        delayInSeconds = self.c_UrgentRefreshDelayAfterUpdate
    end

    -- If passed with a delay, we will schedule it to start in that time.
    if delayInSeconds then
        debugp("Starting a %ss delayed ItemResult Refresh", delayInSeconds)
        refresh.delayTimer = C_Timer.NewTimer(delayInSeconds, doStartItemRefresh)
        Addon:RaiseEvent(ITEMRESULT_REFRESH_TRIGGERED, delayInSeconds)
    else
        debugp("Starting immediate ItemResult Refresh. Force = %s", tostring(forceNext))
        Addon:RaiseEvent(ITEMRESULT_REFRESH_TRIGGERED, 0)
        doStartItemRefresh()
    end
end

-- Called when the item result cache is cleared.
function Status:OnItemResultCacheCleared()
    debugp("Itemresult cache was cleared, stopping refresh in progress and restarting.")

    -- Halt any scan in progress
    Status:StopItemResultRefresh()

    -- Rules changed or something else significant, lets give it a few seconds
    -- for more changes to occur before we do the refresh.
    Status:StartItemResultRefresh(Status.c_RefreshDelayAfterUpdate)
end

function Status:OnPlayerLeavingCombat()
    -- We may have had a refresh underway during combat, which would be cancelled and blocked.
    -- So when player leaves combat, see if we had one such event, and if so, complete the
    -- refresh.
    if refresh.abortedScanDueToCombat then
        debugp("Retriggering scan now that combat has ended.")
        refresh.abortedScanDueToCombat = false
        Status:StartItemResultRefresh(Status.c_RefreshDelayAfterUpdate)
    end
end

-- Fires when a bag changes. 
function Status:OnBagUpdate(bagID)
    -- When a bag changes some items inside it have changed, but we don't know which ones.
    -- Refresh will figure out what ones changed and update the ones that changed.
    -- Use a delay so multiple looting events close together don't have us doing extra work.
    -- Bag updates happen a lot, and we want to be non-intrusive to the player experience.
    -- Using delayed refresh means we will not do any work on a looting event or when items
    -- first appear in the inventory unless players specifically mouse over those items before
    -- we refresh them.
    Status:StartItemResultRefresh(Status.c_RefreshDelayAfterUpdate)
end

function Status:OnPlayerEquipmentChanged(slotID)
    -- When player equipment changes, we could likely have some rule evaluations changed, so
    -- we should start a refresh with force function flagged so we always rebuild the cache
    -- after such an event.
    Status:SetForceUpdateNextRefresh()
    Status:StartItemResultRefresh(Status.c_RefreshDelayAfterUpdate)
end
