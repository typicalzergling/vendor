--[[===========================================================================
    | thread.lua
    |
    | Sets up coroutine handling and management, simulating thread-like
    | funcionality. This allows you to queue up work and then do it later in
    | the background without causing a perf hit to your client. This can avoid
    | UI hangs and throttling by blizzard, which can disconnect the player.
    | This will wrap the function and execute it as a thread.
    |
    | Methods:
    |   AddThread
    |   GetThread
    |   RemoveThread
    |   AddThreadCompletionCallback
    |
    =======================================================================--]]
local AddonName, Addon = ...

local threads = {} 



-- This allows adding a callback function whenever a thread of the specified name is completed.
local threadCallbacks = {}
function Addon:AddThreadCompletionCallback(name, func)
    assert(type(name) == "string" and type(func) == "function")
    if not threadCallbacks[name] then
        threadCallbacks[name] = {}
    end
    table.insert(threadCallbacks[name], func)
end


-- This is a listener frame used for waking up processing threads.
-- Threads go into a queue and the throttler processes them one at a time, FIFO
-- This frame is hidden/shown to turn off/on the listener, so it only checks for work when you want it to.
local counter = 0
local processingFrame = CreateFrame("Frame")
processingFrame:Hide()

local function hasWorkToDo()
    if #threads > 0 then
        return true
    else
        return false
    end
end

-- Wake up the next thread in the queue and do processing.
-- Assumes the threads will yield on their own so this doesn't hang the UI or cause a disconnect.
-- If the coroutine needs to stop, it should be baked into the coroutine itself.
local function doSomeWork()

    -- Go through the thread queue.
    while hasWorkToDo() do
        -- check if thread is dead
        -- if yes, clean it up
        if coroutine.status(threads[1].thread) == "dead" then
            local name = threads[1].name
            Addon:Debug("threads", "Thread %s is complete.", name)
            table.remove(threads, 1)
            -- execute all callbacks for this thread
            if threadCallbacks[name] then
                for _, cb in pairs(threadCallbacks[name]) do
                    Addon:Debug("threads", "Executing callback for thread %s", name)
                    cb()
                end
            end
        else
            -- if not, resume it
            coroutine.resume(threads[1].thread)
            return
        end
    end

    -- If we get here it means there is no work to do so stop listening for it.
    processingFrame:Hide()
end

processingFrame:SetScript("OnUpdate", function(self, elapsed)
    counter = counter + elapsed
    -- Set a reasonable throttle time to start with, addon can override in a constant.
    local throttletime = 0.10
    if Addon.c_ThrottleTime and type(Addon.c_ThrottleTime) == "number" then
        throttletime = Addon.c_ThrottleTime
    end
    if counter >= throttletime then
        counter = counter - throttletime

        -- Do some processing on the next thread.
        doSomeWork()
    end
end)

-- Accessor for adding a thread to the processor. Duplicate names are allowed.
function Addon:AddThread(func, name)
    assert(type(func) == "function", "First argument to AddThread must be a function.")
    assert(type(name) == "string", "Second argument to AddThread must be a string.")
    local obj = {}
    obj.thread = coroutine.create(func)
    obj.name = name
    table.insert(threads, obj)
    self:Debug("threads", "Added thread: %s",tostring(name))

    -- "wake up" the listener
    processingFrame:Show()
end

-- Accessor for getting a thread from the processor
-- Returns the first match if there are duplicates.
function Addon:GetThread(name)
    -- search thread list
    for _, r in pairs(threads) do
        if r.name == name then
            return r
        end
    end
    -- not found
    return nil
end

-- Accessor for removing a thread from the processor.
-- Will remove all that match the name.
-- When a coroutine has no references it is killed after its last yield.
-- LUA is not really multi-threaded so we don't need to worry about synchronization.
function Addon:RemoveThread(name)
    -- search thread list
    for k, v in pairs(threads) do
        if v.name == name then
            table.remove(threads, k)
            self:Debug("threads", "Removed thread: %s", tostring(name))
        end
    end
end


