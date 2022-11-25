-- Includes methods and mechanisms for determining whether data cached data is or needs updating.
-- Also schedules and provides status on any such updating.
-- Data refresh is intended to be a performance improvement system, so it is expected that data
-- may be stale for some period of time, and in most cases that is OK. This system is for how and
-- when we refresh that data and for determining if a given item needs refreshing.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("refresh", ...) end

local Status = Addon.Features.Status

Status.c_RefreshThrottleRate = .05
Status.c_RefreshItemsPerCycle = 4
Status.c_RefreshThreadName = "ItemRefresh"
Status.c_RefreshDelayAfterUpdate = 10        -- Seconds after an update before we kick off a refresh

-- Refresh Events
local ITEMRESULT_REFRESH_TRIGGERED = Addon.Events.ITEMRESULT_REFRESH_TRIGGERED
local ITEMRESULT_REFRESH_START = Addon.Events.ITEMRESULT_REFRESH_START
local ITEMRESULT_REFRESH_STOP = Addon.Events.ITEMRESULT_REFRESH_STOP
local ITEMRESULT_REFRESH_COMPLETE = Addon.Events.ITEMRESULT_REFRESH_COMPLETE

-- Refresh data initialization
local refresh = {}
refresh.delayTimer = nil

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

-- forceNext is an option where we are guaranteed to force an update
-- on the next refresh, even if non-forced refeshes are also triggered.
local forceNext = false
local abortedScanDueToCombat = false
local function doStartItemRefresh(forceUpdate)
    forceUpdate = forceUpdate or forceNext
    -- Clear the delay timer
    cancelDelayTimer()

    -- Check for combat, do not interfere!
    if UnitAffectingCombat("player") then
        debugp("Player is in combat, cancelling scan. Will resume after combat.")
        abortedScanDueToCombat = true
        return
    end

    -- Check if we are already in progress
    if Status:IsItemResultRefreshInProgress() then
        -- If already in progress then stop it so we can restart from beginning.
        Status:StopItemResultRefresh()
    end

    -- begin refresh thread
    local thread = function()   -- Coroutine Begin
        debugp("Refresh Started")
        Addon:RaiseEvent(ITEMRESULT_REFRESH_START)
        local profile = Addon:GetProfile()
        local refreshThrottle = profile:GetValue(Addon.c_Config_RefreshThrottle) or 1
        debugp("Starting bag scan")
        local numProcessed = 0
        local start = GetTime()
        for bag=0, Addon:GetNumTotalEquippedBagSlots() do
            for slot=1, Addon:GetContainerNumSlots(bag) do

                -- If we are in combat, stop the scan.
                if UnitAffectingCombat("player") then
                    debugp("Player entered combat, aborting refresh.")
                    if forceUpdate then
                        forceNext = true
                    end
                    abortedScanDueToCombat = true
                    return
                end

                if forceUpdate or Addon:IsBagAndSlotRefreshNeeded(bag, slot) then
                    Addon:RefreshBagAndSlot(bag, slot, true)
                end

                -- Yield per throttling setting.
                numProcessed = numProcessed + 1
                if numProcessed % Status.c_RefreshItemsPerCycle == 0 then
                    coroutine.yield()
                end
            end
        end

        debugp("Refresh Completed. Elapsed: %ss", tostring(GetTime()-start))
        Addon:RaiseEvent(ITEMRESULT_REFRESH_COMPLETE)
    end -- Coroutine End

    -- Add thread to the thread list and start it.
    Addon:AddThread(thread, Status.c_RefreshThreadName, Status.c_RefreshThrottleRate)
end

-- ItemResultRefresh has optional argument for delay in seconds.
function Status:StartItemResultRefresh(delayInSeconds, forceUpdate)
    assert(not delayInSeconds or type(delayInSeconds) == "number")
    if forceUpdate then
        forceNext = true
    end
    -- If we are already pending a delay, this call will overwrite that delay.
    -- Note that immediate call with no delay will always be immediate.
    cancelDelayTimer()

    -- If passed with a delay, we will schedule it to start in that time.
    if delayInSeconds then
        debugp("Starting a %ss delayed ItemResult Refresh", delayInSeconds)
        refresh.delayTimer = C_Timer.NewTimer(delayInSeconds, doStartItemRefresh)
        Addon:RaiseEvent(ITEMRESULT_REFRESH_TRIGGERED, delayInSeconds)
    else
        debugp("Starting immediate ItemResult Refresh. Force = %s", tostring(forceNext))
        doStartItemRefresh(forceNext)
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
    if abortedScanDueToCombat then
        debugp("Retriggering scan now that combat has ended.")
        abortedScanDueToCombat = false
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
    Status:StartItemResultRefresh(Status.c_RefreshDelayAfterUpdate, true)
end
