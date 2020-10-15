
local _, Addon = ...


-- EVENT HANDLING

-- Base frame for event handling.
local eventFrame = CreateFrame("Frame")

-- Event Handling
local events = {}
local function dispatchEvent(handler, ...)
    if type(handler) == "function" then
        handler(...)
    else
        if Addon[handler] then
            -- Assume self parameter must be passed
            Addon[handler](Addon, ...)
        else
            assert(false, "Function named "..handler.." not found in "..AddonName)
        end
    end
end 

-- We support multiple handlers for the same event.
local function eventDispatcher(frame, event, ...)
    handler = events[event]

    if not handler then
        assert(false, "Event was registered and did not appear in the events list. Event="..tostring(event))
    end
    
    if type(handler) == "table" then
        -- Execute all handlers for this event.
        for k, v in ipairs(handler) do
            dispatchEvent(v, ...)
        end
    else
        dispatchEvent(handler, ...)
    end
end 

local function registerEvent(event, handler)
    -- If the event handler doesn't already exist
    if not events[event] then
        events[event] = handler
    else 
        -- Check if we need to convert it to table    
        if type(events[event] ~= "table") then
            local firstHandler = events[event]
            events[event] = {}
            table.insert(events[event], firstHandler)
        end
        
        -- Add to the table
        table.insert(events[event], handler)
    end
end

-- Define Register Event
function Addon:RegisterEvent(event, handler)
    assert(event and type(event) == "string", "Invalid arguments to RegisterEvent - Must specify a string")
    assert(handler and (type(handler) == "function" or type(handler) == "string"), "Invalid arguments to RegisterEvent - Handler must be string or function")

    -- If this is a new event, we need to register for it with the frame.
    if not events[event] then
        eventFrame:RegisterEvent(event)
    end
    
    -- Register the handler with the event.
    registerEvent(event, handler)
end

-- Removes ALL event handlers registered for a particular event and unregisters it with the frame.
-- Since we are no longer listening to this event it is completely gone.
-- This is intending for load/unload scenarios, be sure to re-register all events needed when re-enabling.
function Addon:UnregisterEvent(event)
    if not events[event] then return end
    events[event] = nil
    eventFrame:UnregisterEvent(event)
end

-- Set the script to use the event Dispatcher.
eventFrame:SetScript("OnEvent", eventDispatcher)


