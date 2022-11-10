-- Includes methods and mechanisms for determining whether data cached data is or needs updating.
-- Also schedules and provides status on any such updating.
-- Data refresh is intended to be a performance improvement system, so it is expected that data
-- may be stale for some period of time, and in most cases that is OK. This system is for how and
-- when we refresh that data and for determining if a given item needs refreshing.

local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("refresh", ...) end

-- Refresh Events
local REFRESH_NEEDED = Addon.Events.REFRESH_NEEDED
local REFRESH_START = Addon.Events.REFRESH_START
local REFRESH_STOP = Addon.Events.REFRESH_STOP
local REFRESH_COMPLETE = Addon.Events.REFRESH_COMPLETE
local REFRESH_ITEM_UPDATED = Addon.Events.REFRESH_ITEM_UPDATED

-- Refresh data initialization
local refresh = {}
refresh.threadName = Addon.c_RefreshThreadName
refresh.isRefreshNeeded = true
refresh.isInProgress = false
refresh.delayTimer = nil
refresh.stop = false

function Addon:IsRefreshNeeded()
    return refresh.isRefreshNeeded
end

function Addon:SetRefreshNeeded()
    print("Test")
    debugp("Refresh Needed")
    refresh.isRefreshNeeded = true
    Addon:RaiseEvent(REFRESH_NEEDED)
    -- Check if refresh is in progress, if so we need to start over.
end

function Addon:IsRefreshInProgress()
    -- We are refreshing if we have a thread active.
    return not not self:GetThread(refresh.threadName)
end

local scopetest
function Addon:StopRefresh()
    if self:IsRefreshInProgress() then
        debugp("Signalling Refresh Stop")
        refresh.stop = true
        scopetest = "Should have stopped!"
    end
end

function Addon:StartRefreshDelayed(delayInSeconds)
    assert(type(delayInSeconds) == "number")
    -- If we are already pending a delay, push it back again.
    if refresh.delayTimer then
        debugp("Refresh already delayed, delaying again...")
        refresh.delayTimer:Cancel()
    end
    refresh.delayTimer = C_Timer.NewTimer(delayInSeconds, Addon.StartRefresh)
end

function Addon:StartRefresh()
    -- Clear the delay timer
    if refresh.delayTimer then
        debugp("Clearing delay timer on start.")
        refresh.delayTimer:Cancel()
        refresh.delayTimer = nil
    end

    -- Check if we are already in progress
    if Addon:IsRefreshInProgress() then
        -- Skip for now, but should restart the refresh if requested while in progress.
        debugp("Refresh is in progress, delaying 3 seconds...")
        Addon:StopRefresh()
        Addon:StartRefreshDelayed(3)
        return
    end

    -- begin refresh thread
    local thread = function()   -- Coroutine Begin
        debugp("Refresh Started")
        refresh.stop = false
        scopetest = "No stop encountered yet..."
        Addon:RaiseEvent(REFRESH_START)
        local profile = Addon:GetProfile()
        local refreshThrottle = profile:GetValue(Addon.c_Config_RefreshThrottle) or 1

        debugp("Starting bag scan")
        local numProcessed = 0
        for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            debugp("Scopetest: %s", scopetest)
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                -- Check if something stopped us between the last yield
                if refresh.stop then
                    -- This never executes...
                    debug("Stopping Refresh")
                    Addon:StopThread(refresh.threadName)
                    Addon:RaiseEvent(REFRESH_STOP)
                    return
                end

                -- Process an item refresh
                numProcessed = numProcessed + 1

                -- Yield per throttling setting.
                if numProcessed % refreshThrottle == 0 then
                    coroutine.yield()
                end
            end
        end

        debugp("Refresh Completed")
        Addon:RaiseEvent(REFRESH_COMPLETE)
    end -- Coroutine End

    -- Add thread to the thread queue and start it.
    Addon:AddThread(thread, refresh.threadName, .03)
end

