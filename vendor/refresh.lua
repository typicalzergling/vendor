-- Includes methods and mechanisms for determining whether data cached data is or needs updating.
-- Also schedules and provides status on any such updating.
-- Data refresh is intended to be a performance improvement system, so it is expected that data
-- may be stale for some period of time, and in most cases that is OK. This system is for how and
-- when we refresh that data and for determining if a given item needs refreshing.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("refresh", ...) end

-- Refresh Events
local ITEMRESULT_REFRESH_TRIGGERED = Addon.Events.ITEMRESULT_REFRESH_TRIGGERED
local ITEMRESULT_REFRESH_START = Addon.Events.ITEMRESULT_REFRESH_START
local ITEMRESULT_REFRESH_STOP = Addon.Events.ITEMRESULT_REFRESH_STOP
local ITEMRESULT_REFRESH_COMPLETE = Addon.Events.ITEMRESULT_REFRESH_COMPLETE

-- Refresh data initialization
local refresh = {}
refresh.threadName = Addon.c_RefreshThreadName
refresh.delayTimer = nil


local function cancelDelayTimer()
    if refresh.delayTimer then
        refresh.delayTimer:Cancel()
        refresh.delayTimer = nil
    end
end

function Addon:IsItemResultRefreshInProgress()
    -- We are refreshing if we have a thread active.
    return not not Addon:GetThread(refresh.threadName)
end

function Addon:StopItemResultRefresh()
    if Addon:IsItemResultRefreshInProgress() then
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
    if Addon:IsItemResultRefreshInProgress() then
        -- If already in progress then stop it so we can restart from beginning.
        Addon:StopItemResultRefresh()
    end

    -- begin refresh thread
    local thread = function()   -- Coroutine Begin
        debugp("Refresh Started")
        Addon:RaiseEvent(ITEMRESULT_REFRESH_START)
        local profile = Addon:GetProfile()
        local refreshThrottle = profile:GetValue(Addon.c_Config_RefreshThrottle) or 1
        debugp("Starting bag scan")
        local numProcessed = 0
        for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            for slot=1, C_Container.GetContainerNumSlots(bag) do

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
                    numProcessed = numProcessed + 1
                end

                -- Yield per throttling setting.
                if numProcessed % refreshThrottle == 0 then
                    numProcessed = 0
                    coroutine.yield()
                end
            end
        end

        debugp("Refresh Completed")
        Addon:RaiseEvent(ITEMRESULT_REFRESH_COMPLETE)
    end -- Coroutine End

    -- Add thread to the thread list and start it.
    Addon:AddThread(thread, refresh.threadName, Addon.c_RefreshThrottleTime)
end

-- ItemResultRefresh has optional argument for delay in seconds.
function Addon:StartItemResultRefresh(delayInSeconds, forceUpdate)
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
function Addon:OnItemResultCacheCleared()
    debugp("Itemresult cache was cleared, stopping refresh in progress and restarting.")

    -- Halt any scan in progress
    Addon:StopItemResultRefresh()

    -- Rules changed or something else significant, lets give it a few seconds
    -- for more changes to occur before we do the refresh.
    Addon:StartItemResultRefresh(4)
end

function Addon:OnPlayerLeavingCombat()
    -- We may have had a refresh underway during combat, which would be cancelled and blocked.
    -- So when player leaves combat, see if we had one such event, and if so, complete the
    -- refresh.
    if abortedScanDueToCombat then
        debugp("Retriggering scan now that combat has ended.")
        abortedScanDueToCombat = false
        Addon:StartItemResultRefresh(4)
    end
end

function Addon:InitializeItemResultRefresh()
    Addon:RegisterCallback(Addon.Events.ITEMRESULT_CACHE_CLEARED, Addon, Addon.OnItemResultCacheCleared)
end