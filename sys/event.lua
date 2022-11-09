
local AddonName, Addon = ...


-- EVENT HANDLING

-- Base frame for event handling.
local eventFrame = CreateFrame("Frame")
local eventBroker = Mixin({}, CallbackRegistryMixin)
CallbackRegistryMixin.OnLoad(eventBroker)
Addon.eventBroker = eventBroker

-- Event Handling
local events = {}
local function dispatchEvent(handler, ...)
    if type(handler) == "function" then
        xpcall(handler, CallErrorHandler, ...)
    else
        if Addon[handler] then
            -- Assume self parameter must be passed
            xpcall(Addon[handler], CallErrorHandler, Addon, ...)
        else
            assert(false, "Function named "..handler.." not found in "..AddonName)
        end
    end
end

-- We support multiple handlers for the same event.
local function eventDispatcher(frame, event, ...)
    Addon:Debug("events", "Dispatching for Event: %s", tostring(event))
    local handler = events[event]

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

-- Registers a callback for the specified event
function Addon:RegisterCallback(event, target, handler)
    assert(event and type(event) == "string", "The event must be a string")
    assert(target and type(target) == "table", "The target must be an object")
    assert(type(handle) == "string" or type(handler) == "function", "The handler must be a string or function")

    -- Register the event with a thunk
    Addon:Debug("events", "Registering callback for event '%s", event)
    eventBroker:RegisterCallback(event, 
        function(...)            
            --@debug@--
            Addon:Debug("events", "Dispatching event '%s'", event)
            --@end-debug@

            local fn = handler;
            if (type(handler) == "string") then
                fn = target[handler]
            end

            if (type(fn) == "function") then
                local result, msg = xpcall(fn, CallErrorHandler, ...)
                if (not result) then
                    Addon:Debug("error", "Failed to invoke member: %s%s|r", RED_FONT_COLOR_CODE, msg)
                end
            else
                Addon:Debug("events", "Unable to resolve handler for %s", event)
            end
        end, target)
end

-- Removes a callback for the given event
function Addon:UnregisterCallback(event, target)
    Addon:Debug("events", "Unregistering callback for event '%s'", event)
    eventBroker:UnregisterCallback(event, target)
end

-- Raise an event
function Addon:RaiseEvent(event, ...)
    --@debug@--
    Addon:Debug("events", "Raising event '%s'", event)
    --@end-debug@

    eventBroker:TriggerEvent(event, ...)
end

-- Register events which can be raised this is enumeration table 
-- example: { MY_EVENT = "event" }
function Addon:GenerateEvents(events)
    assert(events and type(events) == "table", "The events argument must be a table")
    
    local e = {}
    for _, event in pairs(events) do
        table.insert(e, event)
    end

    eventBroker:GenerateCallbackEvents(e)
end

-- Unregisters events which can be raised takes the ssame argument as the function above
function Addon:RemoveEvents(event)
    assert(events and type(events) == "table", "The events argument must be a table")
    
    local e = {}
    for _, event in pairs(events) do
        table.insert(e, event)
    end

    eventBroker:UnregisterEvents(e)
end

-- Checks if the addon raises the specified event
function Addon:RaisesEvent(event)
    return eventBroker:DoesFrameHaveEvent(event)
end