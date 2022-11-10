-- Includes methods and mechanisms for determining whether data cached data is or needs updating.
-- Also schedules and provides status on any such updating.
-- Data refresh is intended to be a performance improvement system, so it is expected that data
-- may be stale for some period of time, and in most cases that is OK. This system is for how and
-- when we refresh that data and for determining if a given item needs refreshing.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("refresh", ...) end

-- Refresh Events
local REFRESH_START = Addon.Events.REFRESH_START
local REFRESH_STOP = Addon.Events.REFRESH_STOP
local REFRESH_COMPLETE = Addon.Events.REFRESH_COMPLETE
local REFRESH_ITEM_UPDATED = Addon.Events.REFRESH_ITEM_UPDATED

-- Refresh data initialization
local refresh = {}
refresh.threadName = Addon.c_RefreshThreadName
refresh.delayTimer = nil

function Addon:IsRefreshInProgress()
    -- We are refreshing if we have a thread active.
    return not not Addon:GetThread(refresh.threadName)
end

function Addon:StopRefresh()
    if Addon:IsRefreshInProgress() then
        debugp("Stopping the refresh thread.")
        Addon:RemoveThread(refresh.threadName)
        Addon:RaiseEvent(REFRESH_STOP)
    end
end

function Addon:StartRefreshDelayed(delayInSeconds)
    assert(type(delayInSeconds) == "number")

    -- If we are already pending a delay, push it back again.
    if refresh.delayTimer then
        debugp("Refresh already delayed, delaying again...")
        refresh.delayTimer:Cancel()
    end
    debugp("Starting a %ss delayed Refresh", delayInSeconds)
    refresh.delayTimer = C_Timer.NewTimer(delayInSeconds, Addon.StartRefresh)
end

function Addon:StartRefresh()
    -- Clear the delay timer
    if refresh.delayTimer then
        refresh.delayTimer:Cancel()
        refresh.delayTimer = nil
    end

    -- Check if we are already in progress
    if Addon:IsRefreshInProgress() then
        -- If already in progress then stop it so we can restart from beginning.
        Addon:StopRefresh()
    end

    -- begin refresh thread
    local thread = function()   -- Coroutine Begin
        debugp("Refresh Started")
        Addon:RaiseEvent(REFRESH_START)
        local profile = Addon:GetProfile()
        local refreshThrottle = profile:GetValue(Addon.c_Config_RefreshThrottle) or 1
        debugp("Starting bag scan")
        local numProcessed = 0
        for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            for slot=1, C_Container.GetContainerNumSlots(bag) do

                -- Check if slot needs refreshing
                if Addon:LocationNeedsRefresh(bag, slot) then
                    -- do the refresh
                    Addon:RefreshLocation(bag, slot)
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
        Addon:RaiseEvent(REFRESH_COMPLETE)
    end -- Coroutine End

    -- Add thread to the thread list and start it.
    Addon:AddThread(thread, refresh.threadName, Addon.c_RefreshThrottleTime)
end

function Addon:LocationNeedsRefresh(bag, slot)
    -- Do stuff
    return true
end

function Addon:RefreshLocation(bag, slot)
    -- Do stuff
    return
end