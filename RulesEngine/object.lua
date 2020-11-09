local AddonName, Addon = ...;
local _, Package = ...;
local EVENT_DATA_KEY = {};
local EVENT_NAME_KEY = {};
local EVENT_METATABLE = {};
local EVENT_PREFIX = "Event-";

--[[===========================================================================
    | object_MemberNotFound
    |   This raises a member not found exception when the specified member
    |   wasn't found.
    =======================================================================--]]
local function object_MemberNotFound(self, key, typeName, level)
    error(string.format("The type '%s' does not have member '%s'", (typeName or getmetatable(self)), key), level or 3);
end

--[[===========================================================================
    | object_ReadOnly
    |   This raises an exception when attempting to write to the object table.
    =======================================================================--]]
local function object_ReadOnly(self, key, typeName, level)
    error(string.format("The type '%s' does allow access to set '%s'", (typeName or getmetatable(self)), key), level or 3);
end

--[[===========================================================================
    | event_Call:
    |   This handles raising the event, this will iterate through all of our 
    |   handlers and then invoke them (pcall).
    =======================================================================--]]
local function event_Call(self, ...) 
    local handlers = rawget(self, EVENT_DATA_KEY);
    for _, handler in ipairs(handlers) do
        args = { ... };
        if (table.getn(handler.args) ~= 0) then
            args = { unpack(handler.args), ... };
        end
        local status, msg = xpcall(handler.fn, CallErrorHandler, unpack(args));
        if (not status) then
            print(string.format("Failed to invoke handler for '%s': %s", rawget(self, EVENT_NAME_KEY), msg));
        end
    end
end

--[[===========================================================================
    | event_findHandler
    |   Iterates the handler array, returning the index of the specified 
    |   handler or nil if we didn't find it.
    =======================================================================--]]
local function event_findHandler(handlers, handler)
    for i, h in ipairs(handlers) do
        if (h.fn == handler) then
            return i;
        end
    end        
end

--[[===========================================================================
    | event_Add
    |   Adds the specified handler to the array of handlers, if and only if
    |   it is not already in the list.
    =======================================================================--]]
local function event_Add(self, handler, ...)
    assert(type(handler) == "function", "You can only register functions as event handlers");

    local handlers = rawget(self, EVENT_DATA_KEY);
    if (not event_findHandler(handlers, handler)) then
        table.insert(handlers, { 
            fn = handler,
            args = { ... }
        });
    end
end

--[[===========================================================================
    | event_Remove
    |   This removes the specified handler if found from our array of handlers
    =======================================================================--]]
local function event_Remove(self, handler)
    local handlers = rawget(self, EVENT_DATA_KEY);
    local index = event_findHandler(self, handler);
    if (index) then
        table.remove(handlers, index);
    end        
end

local event_API = {
    Raise = event_Call,
    Add = event_Add,
    Remove = event_Remove,
};

--[[===========================================================================
    | event_Index
    |   Handles delegating API calls to our functions, in the event that 
    |   we cannot find a function this raises a member not found exception.
    =======================================================================--]]
local function event_Index(self, key)
    local member = rawget(event_API, key);
    if (member) then
        return member;
    end
    
    object_MemberNotFound(self, key, EVENT_PREFIX .. rawget(self, EVENT_NAME_KEY, 3));
end

--[[===========================================================================
    | create_event
    |   Global function which allows for the creation of an event object,
    |   The name "OnFoo" is used in place of the type where we generate 
    |   error messages.
    =======================================================================--]]
local function create_event(name)
    assert(type(name) == "string", "They name of the event must be a string");
    local object = 
    {
        [EVENT_DATA_KEY] = {},
        [EVENT_NAME_KEY] = name,
    };

    local mt = 
    {
        __metatable = EVENT_METATABLE,
        __index = event_Index,
        __newindex = function(self, k, v) 
                object_ReadOnly(self, k, (EVENT_PREFIX .. name)); 
            end,
        __call = event_Call,
    };

    return setmetatable(object, mt);
end

--[[===========================================================================
    | create_object_debug
    |   Crates an object which provides only the access to defined API methods
    |   and events on the specified instance. Each method is a thunk to the
    |   method specified (allowing us to proxy them). This adds overhead 
    |   but is helpful to find bugs.
    |
    |   Since we pass instance through the thunk, we need to give that table
    |   a metatable equal to the API we want to expose so that works.
    =======================================================================--]]
local function create_object_debug(name, instance, API)
    setmetatable(instance, {  __index = API });

    local function object_Index(self, key)
        -- Check for a member function
        local member = rawget(API, key);
        if member and (type(member) == "function") then
            return function(self, ...) return member(instance, ...) end;
        end
        
        -- Check for a member event (it lives in the instance)
        local event = rawget(instance, key);
        if event and (type(event) == "table") and (getmetatable(event) == EVENT_METATABLE) then
            return event;
        end

        object_MemberNotFound(self, key, name);
    end;

    local thunk = {};
    return setmetatable(thunk,
        {
            __metatable = name,
            __index = object_Index,
            __newindex = function(self, k, v) 
                    object_ReadOnly(self, k, name);
                end,
        });
end

local TypeInformation = {};

local function Debug_CreateObject(typeName, instance, API)    
    local thunk = {};
    return setmetatable(thunk, {
        __metatable = typeName,
        __index = function(self, key)
        -- Check for a member function
            local member = rawget(API, key);
            if (type(member) == "function") then
                return function(...) 
                        return member(...) 
                    end;
            else
                member = rawget(instance, key);
                if (member ~= nil) then
                    return member;
                end

                error(string.format("Type '%s' has no member '%s'", typeName, key));
            end
        end,
        __newindex = function(self, key, value)
            if (rawget(instance, key) == nil) then
                error(string.format("New members are not allowed on '%s' attempted to set '%s'", typeName, key));                
            else
                rawset(instance, key, value);
            end
        end
    });
end

local function CreateObject_New(typeName, instance, API, events)
    local fullName = string.format("%s.%s", AddonName, typeName);
    local fullApi = rawget(TypeInformation, typeName);
    if (not fullApi) then
        fullApi = {};

        -- Copy the functions over the API
        for name, value in pairs(API) do
            if (type(value) == "function") then
                fullApi[name] = value;
            else
                --@debug@
                error(string.format("Type '%s' API contains member '%s' which is not a function", fullName, name));
                --@end-debug@                    
            end
        end

        -- If the object has events then mixin the callback registry
        if (type(events) == "table") then
            fullApi.RegisterCallback = CallbackRegistryMixin.RegisterCallback;
            fullApi.TriggerEvent = CallbackRegistryMixin.TriggerEvent;
            fullApi.UnregisterCallback = CallbackRegistryMixin.UnregisterCallback;
        end

        rawset(TypeInformation, typeName, fullApi);
    end

    -- If the object has events, then register them
    if (type(events) == "table") then
        CallbackRegistryMixin.OnLoad(instance);
        CallbackRegistryMixin.SetUndefinedEventsAllowed(instance, false);
        CallbackRegistryMixin.GenerateCallbackEvents(instance, events);
    end

    return Debug_CreateObject(fullName, instance, fullApi);
end

--[[===========================================================================
    | create_object
    |   Give the specified API and instance this sets up dispatch to the 
    |   object which only allows for member functions to be called.
    =======================================================================--]]
local function create_object(name, instance, API)
    return create_object_debug(name, instance, API);
--    return setmetatable(instance, { __metatable = name, __index=API });
end

-- Publish our utility functions so the rest of the package can see them
Package.CreateObject = create_object;
Package.CreateEvent = create_event;

-- TEMP
local _, Addon = ...
Addon.CreateEvent = create_event

Addon.CreateObject_N = CreateObject_New;

