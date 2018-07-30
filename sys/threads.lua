local Addon, L = _G[select(1,...).."_GET"]()

-- Thread processor.
-- This allows the addon to queue up work and then do it later in the background without cuasing a perf hit.
-- This is also useful for avoiding throttling by Blizzard.
-- Creation of the actual threads is left to the appropriate files; this just manages them and runs them.
-- This is a general purpose chunk that could be used for a wide variety of processing intensive tasks. In this addon I use it for selling.

local threads = {}                      -- Holds the processing threads

-- This is a listener frame used for waking up processing threads.
-- Threads go into a queue and the throttler processes them one at a time, FIFO
-- This keeps the threads from interfering with the UI and keeps it responsive.
-- This approach can do some very process-intensive work without hanging the UI.
-- This frame is hidden/shown to turn off/on the listener, so it only checks for work when you want it to.
local counter = 0
local processingFrame = CreateFrame("Frame")
processingFrame:Hide()
processingFrame:SetScript("OnUpdate", function(self, elapsed)
    counter = counter + elapsed
    local throttletime = Addon:GetConfig():GetValue(Addon.c_Config_ThrottleTime)
    if counter >= throttletime then
        counter = counter - throttletime

        -- Do some processing on the next thread.
        Addon:DoSomeWork()
    end
end)

-- Wake up the next thread in the queue and do processing.
-- Assumes the threads will yield on their own so this doesn't hang the UI or cause a disconnect.
-- If the coroutine needs to stop, it should be baked into the coroutine itself.
function Addon:DoSomeWork()

    -- Go through the thread queue.
    while self:HasWorkToDo() do
        -- check if thread is dead
        -- if yes, clean it up
        if coroutine.status(threads[1].thread) == "dead" then
            self:Debug("Thread "..threads[1].name.." is complete.")
            table.remove(threads, 1)
        else
            -- if not, resume it
            coroutine.resume(threads[1].thread)
            return
        end
    end

    -- If we get here it means there is no work to do so stop listening for it.
    processingFrame:Hide()
end

function Addon:HasWorkToDo()
    if #threads > 0 then
        return true
    else
        return false
    end
end

-- Accessor for adding a thread to the processor. Duplicate names are allowed.
-- Also wakes up listener, as if you add a thread, surely you intend for it to be executed.
function Addon:AddThread(thread, name)
    local obj = {}
    obj.thread = thread
    obj.name = name
    table.insert(threads, obj)
    self:Debug("Added thread: "..tostring(name))

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
            self:Debug("Removed thread: "..tostring(v.name))
        end
    end
end
